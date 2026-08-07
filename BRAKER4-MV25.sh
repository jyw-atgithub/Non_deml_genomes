#!/bin/bash

module load python/3.14.3 #Snakemake 8.18.2 requires Python 3.11 or higher
#pip install snakemake==8.18.2 --user
#pip install snakemake-executor-plugin-cluster-generic
#pip install snakemake-executor-plugin-slurm==2.6.0 --user

module load singularity/3.11.3

# BRAKER4 with IsoSeq, short-read RNA-Seq, and protein data (dual mode)
# Download the snakemake file from their GitHub

export BRAKER4_CONFIG="/dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation/mv25-config.ini"
export SNAKEMAKE_PROFILE="/dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation/BRAKER4"

# --unlock
#--set-resources rule_name:mem_mb=6000 \
#--resources mem_mb=66666 \
#--default-resources "mem_mb=54321" \
# "cpus_per_task=32"

cd /dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation/BRAKER4
#To run Snakemake using all available CPU cores on your machine, pass the --cores flag without a specific number
snakemake --keep-going --jobs 10 --cores all \
--executor slurm \
--default-resources "slurm_account=jje_lab" "mem_mb_per_cpu=6000"  \
--use-singularity \
--singularity-prefix .singularity_cache \
--singularity-args "-B /dfs7/jje/jenyuw/Non_melanogaster/raw -B /dfs7/jje/jenyuw/Non_melanogaster/filtered/rnaseq -B "/dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation"" \
--latency-wait 120 \
--restart-times 1




## --> BRAKER4 strickly requires pandas==2.0.2, which is tooooooo old for python/3.14.3
## --> Use a micromamba environment with python 3.11
micromamba activate braker4_env
#pip install snakemake==8.18.2 pandas==2.0.2 snakemake-executor-plugin-slurm
#pip install "numpy<2"
# The most critical cutoff is pandas 2.2.2. For NumPy 2.x: Use pandas 2.2.2 or newer.
# Pandas 2.0 - 2.2.11 are NOT compatible with NumPy 2.0

module load singularity/3.11.3

cd /dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation/BRAKER4


