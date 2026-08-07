#!/bin/bash
#SBATCH --job-name=filter
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --cpus-per-task=40

##collecting reads

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
cd $raw
bgzip -d -@ 12 -c Dpse* SSFE_pseudopbscura* test_MV25* |chopper -q 10 -l 42000 -t 16 |bgzip -@ 12 -o ${filtered}/Dpse_MV25_42k.filtered.fastq.gz