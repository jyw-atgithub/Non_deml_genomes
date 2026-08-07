#!/bin/bash
#SBATCH --job-name=v-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=24
#SBATCH --output="verkko-mv25-2.out"
source ~/.bashrc

corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"


micromamba activate verkko2  #verkko2.3 was installed

prefix="Dpse_MV25_1"
verkko -d ${assembly}/verkko_${prefix} --local-memory 240 \
--hifi ${corrected}/MV25_10k.corrected.fastq.gz --nano ${filtered}/Dpse_MV25_30k.filtered.fastq.gz