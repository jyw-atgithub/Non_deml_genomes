#!/bin/bash
#SBATCH --job-name=EDTA
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=40
#SBATCH --output="mv25.EDTA.out"

ref="/dfs7/jje/jenyuw/Non_melanogaster/reference"
egapx_out="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/MV25_egapx"
EDTA="/dfs7/jje/jenyuw/Non_melanogaster/EDTA_TE"
genome="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm/Dpse_MV25_final.fasta"

cd ${EDTA}
module load singularity/3.11.3

#SINGULARITY_CACHEDIR=./
#export SINGULARITY_CACHEDIR
#unset -f which
#singularity pull EDTA.sif docker://quay.io/biocontainers/edta:2.3.0--hdfd78af_0

## The parameter --curatedlib brings with many benefits
## "--anno 1" turns on whole genome annotation.

export PYTHONNOUSERSITE=1
singularity exec EDTA.sif EDTA.pl --genome ${genome} \
--cds ${egapx_out}/complete.cds.fna \
--curatedlib ${ref}/Obscura_group_telo_TEs_renamed.fasta \
--anno 1 \
--sensitive 1 --anno 1 --maxdiv 40 --threads $SLURM_CPUS_PER_TASK