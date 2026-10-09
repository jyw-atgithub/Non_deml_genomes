#!/bin/bash

genome="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm/Dpse_MV25_final.fasta"

cd /dfs7/jje/jenyuw/Non_melanogaster/sandbox

echo -e "chr4\t1\t150000" |\
bedtools getfasta -fi ${genome} -bed - -fo Dpse_chr4_1-150000.fasta
# --> submit this file to YASS (ttps://bioinfo.univ-lille.fr/yass/yass.php) for self comparison

# D-genies and nucmer only produced a clean straight diagonal dotplot.

echo -e "chrY\t1\t100000" |\
bedtools getfasta -fi ${genome} -bed - -fo Dpse_chrY_1-100000.fasta

echo -e "chrY\t41151892\t41251892" |\
bedtools getfasta -fi ${genome} -bed - -fo Dpse_chrY_41151892-41251892.fasta