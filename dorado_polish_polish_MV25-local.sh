#!/bin/bash

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
target="${prim}/Dpse_MV25_8.p_ctg.fasta.gz"

##On local Machine

cd /mnt/c/data/Polishing

target="Dpse_MV25_12-2.BOTH_haps.fasta.gz"
bam="dorado-aligner_reads-hifiasm_12-2.BOTH_haps.sorted.bam"
#output fastQ
dorado polish --device cuda:0 -v --ignore-read-groups --qualities ${bam} ${target} |\
bgzip -@ 2 -c >dorado-ploished_Dpse_MV25_hifiasm_12-2_hap1.fastq.gz

# Polishing both haplotypes did not work because dorado polish skip the reads with MAPQ=0, i.e., the reads that map to both haplotypes equally well. Working on the major haplotype is enough.
#dorado polish --device cuda:0 --ignore-read-groups --qualities ${bam} ${target} |\
#bgzip -@ 2 -c >dorado-polished_Dpse_MV25_hifiasm_12-2_BOTH_haps.fastq.gz