#!/bin/bash
#SBATCH --job-name=mv25-8-2
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=36
#SBATCH --output="mv25_hifiasm-8-2.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dpse_MV25_8-2"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 1 --dual-scaf --ont --rl-cut 50000 ${filtered}/Dpse_MV25_42k.filtered.fastq.gz

for i in ${assembly}/hifiasm_${prefix}/*.p_ctg.gfa
do
gawk '/^S/{print ">"$2;print $3}' ${i} |bgzip -@ 4 -c > `basename ${i} .gfa`.p_ctg.fasta.gz
done