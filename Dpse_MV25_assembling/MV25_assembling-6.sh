#!/bin/bash
#SBATCH --job-name=asm6
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=48
#SBATCH --mem-per-cpu=6G
#SBATCH --output="hifi.%A_%a.out"

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

f_read=${filtered}/MV25_5k.fastq.gz
c_read=${corrected}/MV25_5k.corrected.fasta.gz
prefix="MV25_6"

mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}
hifiasm --primary -t ${nT} -o ${prefix} --dual-scaf --ul-rate 0.00923 -l 0 -N 500 -n 2 --ctg-n 2 --ul-tip 2 \
--path-max 0.55 --path-min 0.16 \
--ul ${f_read} ${c_read}
wait
awk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta