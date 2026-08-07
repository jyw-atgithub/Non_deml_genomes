#!/bin/bash
#SBATCH --job-name=h-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=24
#SBATCH --output="hifiasm-2.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

#cat Dpse_40k_duplex_only_Q10_5mC_5hmC_6mA.fastq.gz SSFE_pseudopbscura_MV25_Enrich3_duplex_only.fastq.gz SSFE_pseudopbscura_MV25_Sep10_DMSO20_duplex_only.fastq.gz test_MV25_duplex_only.fastq.gz > ../filtered/MV25_all_duplex_only.fastq.gz

prefix="Dpse_MV25_2"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --primary --ul-rate 0.02 \
--ul ${filtered}/Dpse_MV25_30k.filtered.fastq.gz ${filtered}/MV25_all_duplex_only.fastq.gz
