#!/bin/bash
#SBATCH --job-name=asm5
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=56
#SBATCH --mem-per-cpu=6G
#SBATCH --output="verkko.%A_%a.out"

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"
ref="/dfs7/jje/jenyuw/Non_melanogaster/reference/GCF_009870125.1_UCI_Dpse_MV25_genomic.fna"

f_read=${filtered}/MV25_5k.fastq.gz
c_read=${corrected}/MV25_5k.corrected.fasta.gz
prefix="MV25_5"

micromamba activate verkko2
verkko -d ${assembly}/verkko_${prefix} --hifi ${c_read} --nano ${f_read}  \
--mbg-run 50 330 96 \
--local --local-memory 300 --local-cpus ${nT} \
--haploid --ref ${ref}
micromamba deactivate
