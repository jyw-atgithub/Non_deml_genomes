#!/bin/bash

filtered="/dfs7/jje/jenyuw/Non_melanogaster/filtered"
prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
mer_out="/dfs7/jje/jenyuw/Non_melanogaster/merqury_out"
export MERQURY="/pub/jenyuw/Software/merqury-1.4.1"

#bash $MERQURY/best_k.sh 200000000
#It gave 18.77. BUT the documantation said: "Thus, I recommend to use k=31 in most cases."
cd $mer_out

meryl k=31 count ${filtered}/illumina_MV25_male.R?.filtered.fastq.gz output MV25.meryl

module load R/4.5.2 # It used R to generate the plots.
bash ${MERQURY}/merqury.sh MV25.meryl ${prim}/Dpse_MV25_final.fasta MV25_out

bash ${MERQURY}/eval/spectra-cn.sh MV25.meryl ${prim}/Dpse_MV25_final.fasta cn
