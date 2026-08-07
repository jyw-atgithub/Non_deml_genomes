#!/bin/bash
#SBATCH --job-name=h-mv25-17
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=36
#SBATCH --output="mv25_hifiasm-17.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"



input="${filtered}/Dpse_MV25_ULK_75k.filtered.fatsq.gz ${filtered}/Dpse_MV25_55k.filtered.fastq.gz"

echo $input

prefix="Dpse_MV25_17"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --rl-cut 60000 --ont ${input}

for i in ${assembly}/hifiasm_${prefix}/${prefix}*ctg.gfa
do
name=`basename ${i} .gfa`
gawk '/^S/{print ">"$2;print $3}' ${i} |bgzip -@ 4 -c > ${name}.fasta.gz
samtools faidx ${name}.fasta.gz
done
