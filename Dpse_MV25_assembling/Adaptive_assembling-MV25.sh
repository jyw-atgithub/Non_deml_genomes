#!/bin/bash
prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
adaptive="/dfs7/jje/jenyuw/Non_melanogaster/adaptive"

target="${prim}/Dpse_MV25_8.p_ctg.fasta.gz"
target_idx="${prim}/Dpse_MV25_8.p_ctg.fasta.gz.fai"

# The head 1.713MBof ptg000003 is centromere and its end is telomere
# The head 19.548MB of ptg000005 is telomere and the tail is centromere
buffer_zone="100000"
gawk -v OFS="\t" -v buffer="${buffer_zone}" ' $2 > buffer*2 {print $1,"1",buffer; print $1,$2-buffer,$2}' ${target_idx} |\
bedtools sort > ${adaptive}/Dpse_MV25_8.p_ctg.buffer.bed

# Because the sequencing deapth is igh enough. We just need to sample both ends of the contigs as mush as possible.
# Current N50 of ultralong = 72~73 kb
# Use enrichment mode. 