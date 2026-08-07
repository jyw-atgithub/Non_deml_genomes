#!/bin/bash
#SBATCH --job-name=sra3           ## job name
#SBATCH -A jje_lab         ## account to charge
#SBATCH -p standard               ## partition name
#SBATCH --ntasks=24                ## CPUs to use as threads in fasterq-dump command
#SBATCH --tmp=200G                ## requesting 100 GB local scratch
#SBATCH --constraint=fastscratch  ## requesting nodes with fast scratch in /tmp

#SRR24006472 male    adult head	MV2-25
#SRR24006427 male    larva whole body	MV2-25
#SRR24006401 male    adult testis	MV2-25
#SRR24006414 not applicable  Stage_12 Larva	MV2-25


cd $TMPDIR

for ID in SRR24006472 SRR24006427 SRR24006401 SRR24006414
do
    # prefetch SRA file
    prefetch $ID

    fasterq-dump ./$ID -e $SLURM_NTASKS --temp $TMPDIR --disk-limit-tmp 200G

    # compress resulting fastq files
    bgzip -k -@ $SLURM_NTASKS $ID*fastq
    echo "Finished processing $ID*fastq"
done

# move all results to desired location in DFS, directory must exists
mv *fastq.gz /dfs7/jje/jenyuw/Non_melanogaster/raw/CHIPseq

