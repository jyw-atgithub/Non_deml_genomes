#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH -N 1
#SBATCH --array=1-28
#SBATCH --ntasks=12
#SBATCH --constraint=nvme

#sbatch --dependency=afterok:....... rna_filter_MV25.sh
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
rna="/dfs7/jje/jenyuw/Non_melanogaster/raw/rnaseq"
filtered_rna="/dfs7/jje/jenyuw/Non_melanogaster/filtered/rnaseq"

ID="ERR15566737 ERR15566738 ERR15566739 ERR15566740 ERR15566719 ERR15566731 ERR15566720 ERR15566726 SRR18151013 SRR18151014 SRR4416179 SRR4416168 SRR29261110 SRR23592633 SRR23592632 SRX5995646 SRR6968212 SRR6968195 SRR6968196 SRR6968197 SRR6968198 SRR6968199 SRR6968200 SRR6968207 SRR6968208 SRR6968209 SRR6968210 SRR6968211"

echo $ID |sed  "s/ /\n/g" > ${rna}/rnaseq_list.txt

#wc -l ${rna}/rnaseq_list.txt
# -->28

SRA_ID=`head -n $SLURM_ARRAY_TASK_ID ${rna}/rnaseq_list.txt |tail -n 1`

echo ${SRA_ID}

fastp --detect_adapter_for_pe --cut_tail --cut_mean_quality 20 --average_qual 20 --correction --overrepresentation_analysis \
--html ${rna}/${SRA_ID}.report.html --json /dev/null --thread $SLURM_CPUS_PER_TASK \
-i ${rna}/${SRA_ID}_1.fastq.gz -I ${rna}/${SRA_ID}_2.fastq.gz \
-o ${filtered_rna}/${SRA_ID}_1.filtered.fastq.gz -O ${filtered_rna}/${SRA_ID}_2.filtered.fastq.gz