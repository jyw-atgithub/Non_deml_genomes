#!/bin/bash
#SBATCH --job-name=h-ere
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=36
#SBATCH --output="Dere_hifiasm_2.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dere_2"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --primary --ont ${filtered}/Dere.5k.filtered.fastq.gz

gawk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta.gz