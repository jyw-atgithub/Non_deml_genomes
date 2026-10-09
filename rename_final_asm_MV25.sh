#!/bin/bash
# in interactive mode

cd /dfs7/jje/jenyuw/Non_melanogaster/primary_asm
cat dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta.PolcaCorrected.fa | sed 's/h1tg000006l/chr5/g;s/h1tg000003l/chr3/g;s/h1tg000001l/chr4/g;s/h1tg000005l/chrY/g;s/h1tg000002l/chrX/g' | seqkit grep -r -p "chr" >temp.fa

seqkit grep -p "h1tg000004l" dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta.PolcaCorrected.fa |seqkit seq -t "dna" --reverse --complement|sed 's/h1tg000004l/chr2/g' >>temp.fa

seqkit sort -j 8 -w 0 temp.fa |bgzip -c -@ 4 >Dpse_MV25_final.fasta.gz
bgzip -@ 4 -dk Dpse_MV25_final.fasta.gz