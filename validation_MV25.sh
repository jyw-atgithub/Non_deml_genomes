#!/bin/bash

#SBATCH --job-name=valid
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=nvme
#SBATCH --cpus-per-task=40
#SBATCH --output="validation_mv25_2.out"
prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"


#cp /dfs7/jje/jenyuw/Non_melanogaster/assembly/hifiasm_Dpse_MV25_8/Dpse_MV25_8.p_ctg.fasta.gz ${prim}/Dpse_MV25_8.p_ctg.fasta.gz

target="${prim}/Dpse_MV25_8.p_ctg.fasta.gz"
input="${filtered}/Dpse_MV25_42k.filtered.fastq.gz"

#lr:hqae is for mapping reads to their own assemblies. Not recommended for other use cases.
#lr:hq     Align accurate long reads (error rate <1%) to a reference genome (-k19 -w19 -U50,500 -g10k) --> this produces many errors when reads are mapped to its original assembly.

minimap2 -L --cs -a -x lr:hqae -t $(( $SLURM_CPUS_PER_TASK - 6 )) ${target} ${input} |\
samtools view -@ 2 -bh | samtools sort -m 2G -@ 4 > ${mapping}/Dpse_MV25_42k_reads-hifiasm_8.bam
samtools index -@ 16 ${mapping}/Dpse_MV25_42k_reads-hifiasm_8.bam
samtools depth -@ 16 -a --reference ${target} ${mapping}/Dpse_MV25_42k_reads-hifiasm_8.bam > ${mapping}/Dpse_MV25_42k_reads-hifiasm_8.depth.tsv
#lr:hqae performed much better in this case.



#SRR11813283 was the illumina sequences form 2019/2020 of our D. pseudoobscura.
R1="${raw}/SRR11813283_1.fastq.gz"
R2="${raw}/SRR11813283_2.fastq.gz"

# the "pub (dsf6)" was too slow. Change to a temporary executable.
/dfs7/jje/jenyuw/Non_melanogaster/fastp --detect_adapter_for_pe --cut_tail --cut_mean_quality 20 --average_qual 20 --overrepresentation_analysis \
--html "SRR11813283.report.html" --json /dev/null --thread $SLURM_CPUS_PER_TASK \
-i ${R1} -I ${R2} \
-o ${filtered}/SRR11813283_1.filtered.fastq.gz -O ${filtered}/SRR11813283_2.filtered.fastq.gz

R1="${filtered}/SRR11813283_1.filtered.fastq.gz"
R2="${filtered}/SRR11813283_2.filtered.fastq.gz"

target="${prim}/Dpse_MV25_8.p_ctg.fasta.gz"
bwa index ${target}

bwa mem -t $(( $SLURM_CPUS_PER_TASK - 6 )) ${target} ${R1} ${R2} |\
samtools view -@ 2 -bh -q 20 | samtools sort -m 2G -@ 4 > ${mapping}/Dpse_MV25_illumina-hifiasm_8.filtered.bam
samtools index -@ 16 ${mapping}/Dpse_MV25_illumina-hifiasm_8.filtered.bam
#-->Then view the alignment with IGV.


# Align