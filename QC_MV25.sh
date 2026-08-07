#!/bin/bash
#SBATCH --job-name=asmQC
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=nvme
#SBATCH --cpus-per-task=24

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
merqury_out="/dfs7/jje/jenyuw/Non_melanogaster/merqury_out"
SNP="/dfs7/jje/jenyuw/Non_melanogaster/SNP"

target="${prim}/Dpse_MV25_8.p_ctg.fasta.gz"
R1="${filtered}/SRR11813283_1.filtered.fastq.gz"
R2="${filtered}/SRR11813283_2.filtered.fastq.gz"

echo ${R1} ${R2} >$TMPDIR/filelist.txt

#Use Merqury to check QV of the assembly.
#0.089% is the error rate of Novaseq X. (>85% Q30 up)
#bash /pub/jenyuw/Software/merqury/best_k.sh 200000000 0.0009
#K=18.846 --> use K=19

cd ${merqury_out}
meryl k=19 count ${R1} ${R2} memory=140 threads=24 output ${merqury_out}/SRR11813283.meryl

#Merqury only accept fasta files. Not compressed!!
bgzip -dk -@ 4 $target
target="${prim}/Dpse_MV25_8.p_ctg.fasta"
export MERQURY="/pub/jenyuw/Software/merqury"
bash /pub/jenyuw/Software/merqury/merqury.sh "SRR11813283.meryl" "${target}" "Dpse_MV25_8-SRR11813283"

##The result (Dpse_MV25_8-SRR11813283.qv) was:
##Dpse_MV25_8.p_ctg       7874531 209084542       26.9498 0.00201846

##Calling SNPs and indels with freebayes.
##The short read alignment was already made in "validation_MV25.sh"

target="${prim}/Dpse_MV25_8.p_ctg.fasta"    #freebayes requires uncompressed fasta.
freebayes -f ${target} ${mapping}/Dpse_MV25_illumina-hifiasm_8.filtered.bam --skip-coverage 1000 --min-coverage 10 --min-repeat-size 4 -m 20 -q 20 > ${SNP}/Dpse_MV25_8-SRR11813283.snps.vcf

## Not working:
#/dfs7/jje/jenyuw/Non_melanogaster/SNP/freebayes-parallel <(/dfs7/jje/jenyuw/Non_melanogaster/SNP/fasta_generate_regions.py ${prim}/Dpse_MV25_8.p_ctg.fasta.fai 100000) $SLURM_CPUS_PER_TASK -f ${target} ${mapping}/Dpse_MV25_illumina-hifiasm_8.filtered.bam --skip-coverage 1000 --min-coverage 10 --min-repeat-size 4 -m 20 -q 20 > ${SNP}/Dpse_MV25_8-SRR11813283.snps.vcf

#Filtering the SNPs/indels
vcf="${SNP}/Dpse_MV25_8-SRR11813283.snps.vcf"
bcftools view --threads 4 -i ' QUAL>30 ' ${vcf} -o ${SNP}/Dpse_MV25_8-SRR11813283.all.filtered.vcf

bcftools view --threads 4 -i ' QUAL>30 && TYPE="snp" ' ${vcf} -o ${SNP}/Dpse_MV25_8-SRR11813283.snps.filtered.bcf.gz
bcftools view --threads 4 -i ' QUAL>30 && TYPE="snp" ' ${vcf} -o ${SNP}/Dpse_MV25_8-SRR11813283.snps.filtered.vcf
bcftools view --threads 4 -i ' QUAL>30 && TYPE="indel" ' ${vcf} -o ${SNP}/Dpse_MV25_8-SRR11813283.indels.filtered.bcf.gz

#quick plotting
#I hate this package because of its poor manual. Codes were just copied and pasted.
module load python/3.10.2
vcfstats --vcf ${SNP}/Dpse_MV25_8-SRR11813283.snps.filtered.vcf \
    --outdir ${SNP} \
    --formula 'COUNT(1) ~ CONTIG' \
    --title 'Number of SNPs on each chromosome'

vcfstats --vcf ${SNP}/Dpse_MV25_8-SRR11813283.all.filtered.vcf \
    --outdir ${SNP} \
    --formula 'COUNT(1, group=VARTYPE) ~ CHROM' \
    --title 'SNPs and INDELs on each chromosome'

## --> There are excessive variants called with illumina sequences from 2019!!



####################################################################################
# Do the same thing with two haplotypes from hifiasm_012. Hap1 looks much better.

# Switch to BWA-MEM2
# Switch back to bwa mem because the output bam is not recognized by samtools index. 

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
merqury_out="/dfs7/jje/jenyuw/Non_melanogaster/merqury_out"
SNP="/dfs7/jje/jenyuw/Non_melanogaster/SNP"

R1="${filtered}/SRR11813283_1.filtered.fastq.gz"
R2="${filtered}/SRR11813283_2.filtered.fastq.gz"

target="${prim}/Dpse_MV25_12-2.BOTH_haps.fasta.gz"
prefix=$(basename ${target} .fasta.gz)


bwa index ${target}

bwa mem -t $(( $SLURM_CPUS_PER_TASK - 6 )) ${target} ${R1} ${R2} |\
samtools view -@ 2 -bh -q 20 | samtools sort -m 2G -@ 4 > ${mapping}/${prefix}.filtered.bam
samtools index -@ 16 ${mapping}/${prefix}.filtered.bam

bgzip -dk -@ 4 ${target}
target="${prim}/${prefix}.fasta"

freebayes -f ${target} ${mapping}/${prefix}.filtered.bam --skip-coverage 1000 --min-coverage 10 --min-repeat-size 4 -m 20 -q 20 > ${SNP}/${prefix}.snps.vcf
# --> Use IGV to see the distribution of small variants.