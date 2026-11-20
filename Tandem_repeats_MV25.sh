#!/bin/bash
cd /dfs7/jje/jenyuw/Non_melanogaster/Tandem_repeat
asm="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm/Dpse_MV25_final.fasta"

## seqkit grep cannot be used directly on the assembly in this case because it output the whole sequence.
#seqkit grep -j 12 -s -i -m 3 -p "AAAACTTATCTCCGCTGGCGG" "$asm" 

trf-mod -b 5 -g 7 -s 50 -p 1000 "$asm" >MV25_asm_trfmod_out.tsv
## Select the motif greater then 20 bp and the copy number greater than 10. The repeat motif of centromeres on chr 2, 3, 4 (NOT on chr 5, X, Y) are "AAAACTTATCTCCGCTGGCGG", which length is 21 bp and it can form higher order repeats of 84 or 168 bp. (https://doi.org/10.7554/eLife.49002.017) 
gawk -F "\t" '$4>20 && $5>10 {print}' MV25_asm_trfmod_out.tsv >MV25_asm_trfmod_out.large.tsv
gawk -F "\t" '{print $1"\t"$2"\t"$3}' MV25_asm_trfmod_out.large.tsv |\
sort -k 1,1 -k2,2n >MV25_asm_trfmod_out.large.only-coordinates.bed

bedtools getfasta -fi "$asm" -bed MV25_asm_trfmod_out.large.only-coordinates.bed -fo MV25_asm_trfmod_out.large.seq.fasta
seqkit grep -j 12 -w 0 -s -i -m 3 -p "AAAACTTATCTCCGCTGGCGG" MV25_asm_trfmod_out.large.seq.fasta >MV25_chr234_centromere_motif.fasta

## This reports the copy number of "AAAACTTATCTCCGCTGGCGG"
#grep "^>"  MV25_chr234_centromere_motif.fasta|gawk -F ":" '{print $1}'|sort|uniq -c
#    332 >chr2
#    333 >chr3
#    300 >chr4
#    4 >chrX
#    2 >chrY

## Use the sequence name to get the BED coordinates.
grep "^>" MV25_chr234_centromere_motif.fasta|sed 's/>//g;s/:/\t/g;s/-/\t/g' |\
sort -k 1,1 -k2,2n |bedtools merge -i /dev/stdin >MV25_chr234.centromere_motif.bed


## Try to find the centromere motif on chr X
