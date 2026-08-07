#!/bin/bash
#SBATCH --job-name=h-mv25
#SBATCH -A jje_lab
#SBATCH -p highmem
#SBATCH --mem-per-cpu=8G
#SBATCH --cpus-per-task=28
#SBATCH --output="hifiasm-5.out"

corrected="/dfs7/jje/jenyuw/Non_melanogaster/corrected"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dpse_MV25_5"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --primary \
-ul ${filtered}/Dpse_MV25_30k.filtered.fastq.gz ${corrected}/MV25_10k.corrected.fastq.gz

gawk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta.gz

##The assembly is more fragmented, probably because the coverage is too high.