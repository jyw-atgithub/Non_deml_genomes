#!/bin/bash

## Prepare the curated telomeric TE sequences. 
cd /dfs7/jje/jenyuw/Non_melanogaster/reference
# from:	Christopher Ellison <cee53@hginj.rutgers.edu>
# File source: https://raw.githubusercontent.com/jaehakson/DrosophilaTelomericRetrotransposons/refs/heads/main/telo_TEs_396families_dna.fasta
#Convergence and conflict among telomere specialized transposons across 60 million years of Drosophilid evolution, https://doi.org/10.1101/gr.281112.125

seqkit grep -r -p "pseudoobscura" -w 0 -j 4 telo_TEs_396families_dna.fasta > Dpseudoobscura_only_telo_TEs.fasta

# obscura group, pseudoobscura subgroup: D. pseudoobscura, D. persimilis, D. miranda.
# D. lowei is more like the ourgroup.
seqkit grep -r -p "pseudoobscura" -p "miranda" -p "persimilis" -w 0 -j 4 telo_TEs_396families_dna.fasta > Dpseudoobscura_subgroup_telo_TEs.fasta

seqkit grep -w 0 -j 4 -r -p "pseudoobscura" -p "miranda" -p "persimilis" -p "lowei" -p "azteca" -p "athabasca" -p "ambigua" -p "tristis" -p "obscura" -p "bifasciata" -p "subobscura" telo_TEs_396families_dna.fasta > Obscura_group_telo_TEs.fasta

## Perofrm the RepeatMasker
ref="/dfs7/jje/jenyuw/Non_melanogaster/reference"
repeat="/dfs7/jje/jenyuw/Non_melanogaster/repeat"
genome="/dfs7/jje/jenyuw/Non_melanogaster/repeat/Dpse_MV25_final.fasta"

cd ${repeat}
module load singularity/3.11.3

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -engine ncbi -div 3 -s -xsmall -html -gff \
-lib ${ref}/Dpseudoobscura_only_telo_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-pse-only-telo-output ${genome}

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -engine ncbi -s -xsmall -html -gff \
-lib ${ref}/Dpseudoobscura_only_telo_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-pse-very-relaxed-telo-output ${genome}

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -engine ncbi -div 3 -s -xsmall -html -gff \
-lib ${ref}/Dpseudoobscura_subgroup_telo_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-pse-subgroup-telo-output ${genome}

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -engine ncbi -div 10 -s -xsmall -html -gff \
-lib ${ref}/Dpseudoobscura_subgroup_telo_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-pse-relaxed-telo-output ${genome}

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -s -xsmall -html -gff \
-lib ${ref}/Dpseudoobscura_subgroup_telo_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-pse-subgroup-very-relaxed-telo-output ${genome}
# --> Finally, some telomoeric TEs were found in the head of chromosome Y.

# -engine "crossmatch" was said to be more sensitive but the documentation was not clear. It was not included in the TEtools Singularity image.

## 2018_curated_pse_species_group_TE.fasta was the curated TE library generated in Hill, T., Betancourt, A.J. Extensive exchange of transposable elements in the Drosophila pseudoobscura group. Mobile DNA 9, 20 (2018). https://doi.org/10.1186/s13100-018-0123-6

cat 2018_curated_pse_species_group_TE.fasta telo_TEs_396families_dna.fasta >combined_TEs.fasta

singularity exec dfam-tetools-latest.sif RepeatMasker \
-no_is -norna -nolow -s -xsmall -html -gff -cutoff 200 \
-lib ${ref}/combined_TEs.fasta \
-pa $SLURM_CPUS_PER_TASK \
-dir ${repeat}/MV25-combined-curated-lib-output ${genome}