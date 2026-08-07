#!/bin/bash
#SBATCH --job-name=v-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=24
#SBATCH --output="verkko-mv25-1.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dpse_MV25_1"
source ~/.bashrc

micromamba activate verkko2
#verkko2.3 was installed
verkko -d ${assembly}/verkko_${prefix} --local-memory 240 \
--hifi ${filtered}/MV25_all_duplex_only.fastq.gz --nano ${filtered}/Dpse_MV25_30k.filtered.fastq.gz