#!/bin/bash
#SBATCH --job-name=h-mv25-12
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=36
#SBATCH --output="mv25_hifiasm-12.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

input="${filtered}/Dpse_MV25_ULK_75k.filtered.fatsq.gz ${filtered}/Dpse_MV25_55k.filtered.fastq.gz"

echo $input

prefix="Dpse_MV25_12"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 1 --write-ec --dual-scaf --primary --rl-cut 75000 --ont ${input}

gawk '/^S/{print ">"$2;print $3}' ${assembly}/hifiasm_${prefix}/${prefix}.p_ctg.gfa |bgzip -@ 4 -c > ${prefix}.p_ctg.fasta.gz
samtools faidx ${prefix}.p_ctg.fasta.gz

# --> This resulted telomere-to-telomere assembly!! Hap1 is more clear but it had a weird 40 Mb contig. Hap2 is too short.  