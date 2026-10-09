#!/bin/bash
#SBATCH --job-name=ere10
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=30
#SBATCH --output="Dere_hifiasm_10.out"

raw="/dfs7/jje/jenyuw/Non_melanogaster/raw"
filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
assembly="/dfs7/jje/jenyuw/Non_melanogaster/assembly"

prefix="Dere_10"
mkdir ${assembly}/hifiasm_${prefix}
cd ${assembly}/hifiasm_${prefix}

# At this moment, there are 4 read files. 
# New: Dere_14021022401_RTextraction_2_duplex_Q10_5mC_5hmC_6mA_ULK114.fastq.gz
# Dere_14021022401_RT_SFE_duplex_Q10_5mC_5hmC_6mA.fastq.gz
# Dere_14021022401_SFE_double_duplex_Q10_5mC_5hmC_6mA.fastq.gz
# Derecta_14021_0224_01_duplex_Q10_5mC_5hmC_6mA.fastq.gz

hifiasm -o ${prefix} -t $SLURM_CPUS_PER_TASK -l 0 --dual-scaf --ont --rl-cut 71000 ${raw}/Dere*fastq.gz

for i in ${assembly}/hifiasm_${prefix}/${prefix}*ctg.gfa
do
name=`basename ${i} .gfa`
gawk '/^S/{print ">"$2;print $3}' ${i} |bgzip -@ 4 -c > ${name}.fasta.gz
samtools faidx ${name}.fasta.gz
done
