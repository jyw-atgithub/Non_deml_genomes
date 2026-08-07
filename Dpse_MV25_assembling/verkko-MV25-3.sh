#!/bin/bash
#SBATCH --job-name=v-mv25-3
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=28
#SBATCH --output="verkko-mv25-3.out"
source ~/.bashrc

filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"


micromamba activate verkko2  #verkko2.3 was installed

prefix="Dpse_MV25_3"
corrected_read="/dfs7/jje/jenyuw/Non_melanogaster/assembly/hifiasm_Dpse_MV25_3-2/Dpse_MV25_3-2.ec.fq"
#The read correction was done by hifiasm: hifiasm -o Dpse_MV25_3-2 -t 30 -l 0 --write-paf --write-ec --dual-scaf --primary --ont /dfs7/jje/jenyuw/Non_melanogaster/filtered/Dpse_MV25_30k.filtered.fastq.gz

verkko -d ${assembly}/verkko_${prefix} --local-memory 280 \
--hifi ${corrected_read} --nano ${filtered}/Dpse_MV25_30k.filtered.fastq.gz