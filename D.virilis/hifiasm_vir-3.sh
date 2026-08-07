#!/bin/bash
#SBATCH --job-name=h-vir3
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=60
#SBATCH --output="Dvir_hifiasm_3.out"
#SBATCH -t 14-00

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dvir_3"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --ont --hg-size 400m --rl-cut 45000 ${filtered}/Dvir.20k.filtered.fastq.gz

gawk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta.gz

samtools index ${prefix}.p_ctg.fasta.gz