#!/bin/bash
#SBATCH --job-name=asm
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1-2
#SBATCH --cpus-per-task=51
#SBATCH --mem-per-cpu=6G
#SBATCH --output="asm.%A_%a.out"

source ~/.bashrc
nT=$SLURM_CPUS_PER_TASK
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

f_read=${filtered}/MV25_5k.fastq.gz
c_read=${corrected}/MV25_5k.corrected.fasta.gz
if [[ $SLURM_ARRAY_TASK_ID == 1 ]]
then
mkdir ${assembly}/hifiasm_MV25_1
cd ${assembly}/hifiasm_MV25_1
hifiasm -l 0 --primary -t ${nT} -o MV25_1 --ul-rate 0.01 --ul ${f_read} ${c_read}
wait
awk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_MV25_1/MV25_1.p_ctg.gfa |bgzip -@ 4 -c > MV25_1.p_ctg.fasta
elif [[ $SLURM_ARRAY_TASK_ID == 2 ]]
then
micromamba activate verkko2
verkko -d ${assembly}/verkko_MV25_1 --hifi ${c_read}  --nano ${f_read} --haploid  \
--mbg-run 50 330 96 \
--local --local-memory 300 --local-cpus ${nT}
#--snakeopts "--unlock --default-resources mem_gb=330 n_cpus=56"
#--lay_run <ncpus> <mem-in-gb> <time-in-h> DOES NOT WORK!
# --> best assembly so far.
micromamba deactivate
fi
