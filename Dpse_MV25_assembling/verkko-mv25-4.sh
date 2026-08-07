#!/bin/bash
#SBATCH --job-name=v-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=10G
#SBATCH --cpus-per-task=28
#SBATCH --output="verkko-mv25-4.out"
source ~/.bashrc

micromamba activate verkko2  #verkko2.3 was installed

filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"

prefix="Dpse_MV25_4"
ec_read="/dfs7/jje/jenyuw/Non_melanogaster/assembly/hifiasm_Dpse_MV25_8/Dpse_MV25_8.ec.fq"

## verkko cannot accept duplicated read names!!
seqkit rename -j 28 -w 0 ${ec_read} | bgzip -@ 8 -c > /dfs7/jje/jenyuw/Non_melanogaster/corrected/Dpse_MV25_8.renamed.ec.fq.gz
ec_read="/dfs7/jje/jenyuw/Non_melanogaster/corrected/Dpse_MV25_8.renamed.ec.fq.gz"

seqkit rename -j 28 -w 0 ${filtered}/Dpse_MV25_42k.filtered.fastq.gz| bgzip -@ 8 -c > ${filtered}/Dpse_MV25_42k.renamed.fastq.gz

verkko -d ${assembly}/verkko_${prefix} --local-memory 280 \
--hifi ${ec_read} --nano ${filtered}/Dpse_MV25_42k.renamed.fastq.gz \
--hic1 ${raw}/SRR24006393_1.fastq.gz --hic2 ${raw}/SRR24006393_2.fastq.gz

##The result was garbage ##No path was resolved probably because of the HiC reads.