#!/bin/bash
#SBATCH --job-name=h-mv25-7
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=36
#SBATCH --output="mv25_hifiasm-7.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dpse_MV25_7"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --write-paf --write-ec --dual-scaf --primary --ont ${filtered}/Dpse_MV25_42k.filtered.fastq.gz

gawk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta.gz
samtools faidx ${prefix}.p_ctg.fasta.gz