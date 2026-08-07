#!/bin/bash
#SBATCH --job-name=v-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=32
#SBATCH --output="verkko-mv25-5.out"
source ~/.bashrc

micromamba activate verkko2  #verkko2.3 was installed

filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
ref="/dfs7/jje/jenyuw/Non_melanogaster/reference"

prefix="Dpse_MV25_5"

ec_read="/dfs7/jje/jenyuw/Non_melanogaster/corrected/Dpse_MV25_8.renamed.ec.fq.gz"

#Try refernece guided scaffolding.
verkko -d ${assembly}/verkko_${prefix} --local-memory 320 --haploid \
--ref ${ref}/GCF_009870125.1_UCI_Dpse_MV25_genomic.fna \
--hifi ${ec_read} --nano ${filtered}/Dpse_MV25_42k.renamed.fastq.gz

#--> Very terrible result.