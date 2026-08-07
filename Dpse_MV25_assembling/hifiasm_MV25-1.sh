#!/bin/bash
#SBATCH --job-name=h-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=28
#SBATCH --output="hifiasm-1.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

#filter reads
#cd $raw
#bgzip -@ 8 -d -c SSFE_pseudopbscura_MV25_* test_MV25_duplex_Q10_5mC_5hmC_6mA.fastq.gz Dpse_40k_simplex_only_Q10_5mC_5hmC_6mA.fastq.gz |chopper -q 10 -l 30000 -t 16 |bgzip -@ 8 -c > ../filtered/Dpse_MV25_30k.filtered.fastq.gz

prefix=Dpse_MV25_1
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${assembly}/${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --primary --ul-rate 0.02 \
--ul ${filtered}/Dpse_MV25_30k.filtered.fastq.gz ${raw}/Dpse_40k_duplex_only_Q10_5mC_5hmC_6mA.fastq.gz