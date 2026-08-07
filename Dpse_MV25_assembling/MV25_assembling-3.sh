#!/bin/bash
#SBATCH --job-name=asm
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=51
#SBATCH --mem-per-cpu=6G
#SBATCH --output="asm.%A_%a.out"

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

f_read=${filtered}/MV25_5k.fastq.gz
c_read=${corrected}/MV25_5k.corrected.fasta.gz

micromamba activate verkko2
verkko -d ${assembly}/verkko_MV25_1 --hifi ${c_read}  --nano ${f_read}  \
--mbg-run 50 330 96 \
--local --local-memory 300 --local-cpus ${nT}
micromamba deactivate
