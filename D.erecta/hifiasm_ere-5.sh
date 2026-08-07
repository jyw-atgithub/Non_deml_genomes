#!/bin/bash
#SBATCH --job-name=h-ere5
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=30
#SBATCH --output="Dere_hifiasm_5.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dere_5"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 1 --dual-scaf --ont --primary --rl-cut 50000 ${filtered}/Dere.5k.filtered.fastq.gz

for i in ${assembly}/hifiasm_${prefix}/${prefix}*ctg.gfa
do
name=`basename ${i} .gfa`
gawk '/^S/{print ">"$2;print $3}' ${i} |bgzip -@ 4 -c > ${name}.fasta.gz
samtools faidx ${name}.fasta.gz
done
