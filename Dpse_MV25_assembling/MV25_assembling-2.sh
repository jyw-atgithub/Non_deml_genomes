#!/bin/bash
#SBATCH --job-name=asm
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=60
#SBATCH --mem-per-cpu=4G
#SBATCH --output="asm.%A_%a.out"

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

f_read=${filtered}/MV25_5k.fastq.gz
c_read=${corrected}/MV25_5k.corrected.fasta.gz
prefix="MV25_2"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}
hifiasm -l 0 --primary -t ${nT} -o ${prefix} --ul ${f_read} ${c_read}
wait
awk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta

#--> 799 nodes and only 55 MB asm size. Definately Wrong!