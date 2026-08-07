#!/bin/bash
#SBATCH --job-name=polca
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=40
#SBATCH --output="POLCA-polishing.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
polishing="/dfs7/jje/jenyuw/Non_melanogaster/polishing_asm"

/dfs7/jje/jenyuw/Non_melanogaster/fastp --detect_adapter_for_pe --cut_tail --cut_mean_quality 20 --average_qual 20 --overrepresentation_analysis \
--html "${raw}/illumina_MV25_male.report.html" --json /dev/null --thread $SLURM_CPUS_PER_TASK \
-i "${raw}/MV25_male_illumina_PCRfree/xR096-L6-G1-P001-ATAGGCCA-GTATGTTG-R1.fastq.gz" \
-I "${raw}/MV25_male_illumina_PCRfree/xR096-L6-G1-P001-ATAGGCCA-GTATGTTG-R2.fastq.gz" \
-o ${filtered}/illumina_MV25_male.R1.filtered.fastq.gz -O ${filtered}/illumina_MV25_male.R2.filtered.fastq.gz

cd ${polishing}

# bgzip -@ 4 -dk -c dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fastq.gz |seqkit fq2fa -j 4 -w 0 >dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta

# IMPORTANT: The dorado polishing output was set as fastq, so remeber to transform it intp fasta.

#/pub/jenyuw/Software/MaSuRCA-4.1.4/bin/polca-modified.sh
#polca.sh 
polca.sh -a ${polishing}/dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta \
-r "${filtered}/illumina_MV25_male.R1.filtered.fastq.gz ${filtered}/illumina_MV25_male.R2.filtered.fastq.gz" \
-t $SLURM_CPUS_PER_TASK -m 2G