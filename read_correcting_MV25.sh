#!/bin/bash
#SBATCH --job-name="w501corr"
#SBATCH -A jje_lab
#SBATCH -p hugemem
#SBATCH --cpus-per-task=40
#SBATCH --time=7-00
#SBATCH --output="w501corr.out"
source ~/.bashrc
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"

#Filter only once
bgzip -@ 8 -d -k -c ${raw}/{SSFE_pseudopbscura_MV25_Enrich3,test_MV25,SSFE_pseudopbscura_MV25_Sep10_DMSO20}_duplex_Q10_5mC_5hmC_6mA.fastq.gz|chopper -l 5000 -t 8 | bgzip -@ 8 -c > ${filtered}/MV25_5k.fastq.gz

bgzip -@ 8 -d -k -c ${raw}/{SSFE_pseudopbscura_MV25_Enrich3,test_MV25,SSFE_pseudopbscura_MV25_Sep10_DMSO20}_duplex_Q10_5mC_5hmC_6mA.fastq.gz|chopper -l 1000 -t 8 | bgzip -@ 8 -c > ${filtered}/MV25_1k.fastq.gz


bgzip -@ 8 -d -k -c ${raw}/SSFE_simulans* |chopper -l 1000 -t 8 | bgzip -@ 8 -c > ${filtered}/simulans_1k.fastq.gz

dorado correct --verbose --to-paf ${filtered}/MV25_5k.fastq.gz > ${corrected}/MV25_5k.paf
dorado correct --verbose --to-paf ${filtered}/MV25_1k.fastq.gz > ${corrected}/MV25_1k.paf
dorado correct --verbose --to-paf ${filtered}/simulans_1k.fastq.gz > ${corrected}/simulans_1k.paf


#!/bin/bash
#SBATCH --job-name="mv25corr"
#SBATCH -A jje_lab
#SBATCH -p hugemem
#SBATCH --cpus-per-task=40
#SBATCH --time=7-00
#SBATCH --output="mv25corr.out"
source ~/.bashrc
raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"

#Filter only once
bgzip -@ 10 -d -k -c ${raw}/{SSFE_pseudopbscura_MV25_Enrich3,test_MV25,SSFE_pseudopbscura_MV25_Sep10_DMSO20}_duplex_Q10_5mC_5hmC_6mA.fastq.gz ${raw}/Dpse_40k_simplex_only_Q10_5mC_5hmC_6mA.fastq.gz ${raw}/Dpse_40k_duplex_only_Q10_5mC_5hmC_6mA.fastq.gz |chopper -q 10 -l 10000 -t 10 | bgzip -@ 10 -c > ${filtered}/MV25_10k.fastq.gz

dorado correct --verbose --to-paf ${filtered}/MV25_10k.fastq.gz > ${corrected}/MV25_10k.paf
