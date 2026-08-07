#!/bin/bash

#Quick genome assembling and adaptive sequencing.
##################Remember always use SUP mode!!##################
#Transfer files manually.
#concatenate all passed fastq files into one
#transfer the combined fastq to HPC3

#On HPC3. Do assembling

#!/bin/bash
#SBATCH --job-name="first"
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --cpus-per-task=40
#SBATCH --output="w501.first.out"
source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
wd="/dfs7/jje/jenyuw/Adaptive_assembling"
input="${wd}/w501.sup.combined.fastq.gz"
prefix="w501"

#flye --nano-hq ${wd}/MV25_combined.fastq.gz -t ${nT} -i 2 --read-error 0.0213 -o ${wd}/flye_out
mkdir ${wd}/${prefix}_hi_out
cd ${wd}/${prefix}_hi_out
hifiasm --ont -l 0 --primary -t ${nT} -o ${prefix}_hi_out ${input}
gawk '/^S/{print ">"$2;print $3}' ${wd}/${prefix}_hi_out/${prefix}_hi_out.p_ctg.gfa > ${wd}/${prefix}_hi_out.ctg.fa
samtools faidx ${wd}/${prefix}_hi_out.ctg.fa
gawk -v OFS="\t" ' {print $1,0,$2}' ${wd}/${prefix}_hi_out.ctg.fa.fai > ${wd}/${prefix}_firstdraft.bed
bufferzone=20000
gawk -v OFS="\t" -v buf=$bufferzone ' $3 < buf*2 {print $0};
	$3 >= buf*2 {print $1, $2, buf; print $1, $3-buf, $3}' ${wd}/${prefix}_firstdraft.bed > ${wd}/${prefix}_firstdraft.ends.bed



#Create alignments of reads against the draft assembly
draft="${wd}/${prefix}_hi_out.ctg.fa"
input="${wd}/w501.sup.combined.fastq.gz"
minimap2 -a --cs -x map-ont -t ${nT} $draft $input|samtools view -b -h -q 10 -@ 2|samtools sort -m 2G -@ 2 -o ${wd}/${prefix}_firstdraft_mapped.bam

#Find out the regions of coverage lower than 30x
bam="${wd}/${prefix}_firstdraft_mapped.bam"
min_coverage=30
bufferzone=5000
samtools depth -@ 8 --min-BQ 10 --min-MQ  20 -a -l 3000  --reference $draft $bam |awk -v OFS="\t" -v mc=$min_coverage '$3 < mc {
	if (chr == $1 && prev+1 == $2) {end = $2}
	else {
		if (chr) print chr, start, end
		chr = $1; start = $2; end = $2
	}
	prev = $2
}
END {if (chr) print chr, start, end}' |gawk -v OFS="\t" -v buf=$bufferzone '$2 < buf {print $1, $2, $3+buf}; $2 >= buf {print $1, $2-buf, $3+buf}' |\
sort -k1,1 -k2,2n |bedtools merge -d $bufferzone > ${wd}/${prefix}_firstdraft_lowcov.bed

#gawk -v OFS="\t" '{print $0, $3-$2}' #for checking intervals

cat ${wd}/${prefix}_firstdraft.ends.bed ${wd}/${prefix}_firstdraft_lowcov.bed |bedtools sort|bedtools merge > ${wd}/${prefix}_firstdraft.buffered.bed

#for Depletion mode
bedtools subtract -a ${wd}/${prefix}_firstdraft.bed -b ${wd}/${prefix}_firstdraft.buffered.bed > ${wd}/${prefix}_firstdraft.goodpart.bed

:<<'SKIP'
#Because there are lots of reads shorter than 1000bp in adaptive sampling. It is suspected that some short contigs are contiminations.
minimap2 -a -x asm20 -t 10 Yeast_genome.fasta ${wd}/${prefix}_firstdraft.fasta |samtools view -b -h -@ 2|samtools sort -m 2G -o ${wd}/${prefix}_to_yeast.bam
#--> After viewing the alignment, no specific contigs were aligned to yeast.

#Since there are some small contigs of lowcoverage. Try to remove those suspicious contaminations with NCBI FCS-GX.
FCS="/mnt/c/data/FCS-GX"
export FCS_DEFAULT_IMAGE="${FCS}/fcs-gx.sif"
python3 ${FCS}/fcs.py screen genome --fasta ${draft} --out-dir ${FCS}/MV25_first_out --gx-db "${FCS}" --tax-id 7237
#--image ${FCS}/fcs-gx.sif

zcat h_sapiens.fa.gz | python3 ${FCS}/fcs.py clean genome --action-report ./gx_out/h_sapiens.fa.9606.fcs_gx_report.txt --output clean.fasta --contam-fasta-out contam.fasta

SKIP