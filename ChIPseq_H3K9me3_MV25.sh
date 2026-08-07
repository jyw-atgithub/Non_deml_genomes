#!/bin/bash
#SBATCH --job-name=H3K9me3
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=30
#SBATCH --output="ChIPseq_H3K9me3.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
#/dfs7/jje/jenyuw/Non_melanogaster/raw/CHIPseq

for i in SRR24006472 SRR24006427 SRR24006401 SRR24006414
do
/dfs7/jje/jenyuw/Non_melanogaster/fastp --detect_adapter_for_pe --cut_tail --cut_mean_quality 20 --average_qual 20 --overrepresentation_analysis \
--html "${raw}/CHIPseq/${i}.report.html" --json /dev/null --thread $SLURM_CPUS_PER_TASK \
-i "${raw}/CHIPseq/${i}_1.fastq.gz" \
-I "${raw}/CHIPseq/${i}_2.fastq.gz" \
-o ${filtered}/CHIPseq/${i}.R1.filtered.fastq.gz -O ${filtered}/CHIPseq/${i}.R2.filtered.fastq.gz
done

asm="${prim}/dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta.PolcaCorrected.fa"
/pub/jenyuw/Software/bwa-mem2/bwa-mem2 index ${asm}

for i in SRR24006472 SRR24006427 SRR24006401 SRR24006414
do
R1="${filtered}/CHIPseq/${i}.R1.filtered.fastq.gz"
R2="${filtered}/CHIPseq/${i}.R2.filtered.fastq.gz"

/pub/jenyuw/Software/bwa-mem2/bwa-mem2 mem -t $(($SLURM_CPUS_PER_TASK - 6)) ${asm} ${R1} ${R2} |\
samtools view -@ 2 -bh | samtools collate -@ 2 -O /dev/stdin | samtools fixmate -m -@ 2 /dev/stdin ${mapping}/${i}_Dpse_MV25.H3K9me3.fixmate.bam

samtools sort -@ $(($SLURM_CPUS_PER_TASK / 2)) -m "2G" -O "bam" ${mapping}/${i}_Dpse_MV25.H3K9me3.fixmate.bam |\
samtools markdup -@ $(($SLURM_CPUS_PER_TASK / 2)) -r /dev/stdin ${mapping}/${i}_Dpse_MV25.H3K9me3.dedup.bam

samtools index -@ $SLURM_CPUS_PER_TASK ${mapping}/${i}_Dpse_MV25.H3K9me3.dedup.bam
done

module load python/3.14.3
for i in SRR24006472 SRR24006427 SRR24006401 SRR24006414
do
    # In order to see the repetitive regions, keep the reads with MAPQ=0
    bamCoverage --bam ${mapping}/${i}_Dpse_MV25.H3K9me3.dedup.bam -o ${mapping}/${i}_Dpse_MV25.H3K9me3.bw \
        --binSize 10 \
        --normalizeUsing RPGC --effectiveGenomeSize 207787949 \
        --ignoreForNormalization "h1tg000005l h1tg000002l" \
        --extendReads --numberOfProcessors $SLURM_CPUS_PER_TASK
done

## --> Then, view with IGV.