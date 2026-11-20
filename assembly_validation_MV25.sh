#!/bin/bash
#SBATCH --job-name=depth
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --array=1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=10G
#SBATCH --output="mv25_depth.out"

asm="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm/Dpse_MV25_final.fasta"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
# illumina reads from male Dpse adults, PCR-free library prep.
r1="${filtered}/illumina_MV25_male.R1.filtered.fastq.gz"
r2="${filtered}/illumina_MV25_male.R2.filtered.fastq.gz"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
validation="/dfs7/jje/jenyuw/Non_melanogaster/validation"


## Working on short reads
#/pub/jenyuw/Software/bwa-mem2/bwa-mem2 index ${asm}
/pub/jenyuw/Software/bwa-mem2/bwa-mem2 mem -t $(($SLURM_CPUS_PER_TASK - 6)) ${asm} ${r1} ${r2} |\
samtools view -@ 2 -bh -q 20 |\
samtools sort -@ 4 -o ${mapping}/illumina_MV25_final.bam
samtools index ${mapping}/illumina_MV25_final.bam
samtools depth ${mapping}/illumina_MV25_final.bam > ${validation}/illumina_MV25_final.depth


## Working on long reads
input="${filtered}/Dpse_MV25_ULK_75k.filtered.fatsq.gz ${filtered}/Dpse_MV25_55k.filtered.fastq.gz"
minimap2 -a -x lr:hq -t $(($SLURM_CPUS_PER_TASK - 4)) ${asm} ${input} |\
samtools view -@ 2 -bh -q 20 |\
samtools sort -@ 2 -o ${mapping}/long-read_MV25_final.bam
samtools index ${mapping}/long-read_MV25_final.bam
samtools depth ${mapping}/long-read_MV25_final.bam > ${validation}/long-read_MV25_final.depth

### --> then, go to plot_read_coverage.R