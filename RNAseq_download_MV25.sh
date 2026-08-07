#!/bin/bash
#SBATCH --job-name=sra3           ## job name
#SBATCH -A jje_lab          ## account to charge 
#SBATCH -p standard               ## partition name
#SBATCH -N 1                      ## run on a single node, cant run across multiple nodes
#SBATCH --ntasks=30                ## CPUs to use as threads in fasterq-dump command
#SBATCH --tmp=450G                ## requesting 450 GB local scratch
#SBATCH --constraint=fastscratch  ## requesting nodes with fast scratch in /tmp

# IMPORTANT: load the latest SRA-tools, earlier versions do not handle temporary disk
# TMPDIR is created automatically by SLURM
# change to your temp directory assigned by SLURM to your job
cd $TMPDIR
ID="ERR15566737 ERR15566738 ERR15566739 ERR15566740 ERR15566719 ERR15566731 ERR15566720 ERR15566726 SRR18151013 SRR18151014 SRR4416179 SRR4416168 SRR29261110 SRR23592633 SRR23592632 SRX5995646 SRR6968212 SRR6968195 SRR6968196 SRR6968197 SRR6968198 SRR6968199 SRR6968200 SRR6968207 SRR6968208 SRR6968209 SRR6968210 SRR6968211"

### This can be inproved by downloading eash SRA accession in parallel on multiple arrays and prevent overloading the $TMPDIR

# process all sequences in the ID list
for i in ${ID}
do
  # prefetch SRA file
  prefetch --max-size 100G "$i"

  # convert sra format to fastq format using requested number of threads (slurm tasks)
  # an accession number is specified as a directory
  # temp files are written to fastscratch in $TMPDIR with a 100G limit
  fasterq-dump "$i" -f -e $SLURM_NTASKS --temp $TMPDIR --disk-limit-tmp 450G

  # compress resulting fastq files
  bgzip -@ 12 -k "${i}"*fastq
  # move all results to desired location in DFS, directory must exists
  mv "${i}"*fastq.gz /dfs7/jje/jenyuw/Non_melanogaster/raw/rnaseq/
done

# Download Isoseq

for i in SRR11813291 SRR11813290
do
  # prefetch SRA file
  prefetch --max-size 100G "$i"

  # convert sra format to fastq format using requested number of threads (slurm tasks)
  # an accession number is specified as a directory
  # temp files are written to fastscratch in $TMPDIR with a 100G limit
  fasterq-dump "$i" -f -e $SLURM_NTASKS --temp $TMPDIR --disk-limit-tmp 450G

  # compress resulting fastq files
  bgzip -@ 12 -k "${i}"*fastq
  # move all results to desired location in DFS, directory must exists
  mv "${i}"*fastq.gz /dfs7/jje/jenyuw/Non_melanogaster/raw/rnaseq/
done



## Only some illumina RNAseq were used:
#ERR15566737	Abdomens from 10 wildtype strain virgin males - replicate 1	
#ERR15566738	Abdomens from 10 wildtype strain virgin males - replicate 2
#ERR15566719	Female reproductive tracts from 15 wildtype strain virgin females - replicate 2
#ERR15566731	Female reproductive tracts from 15 wildtype strain virgin females - replicate 4
#SRR18151014	Young male D. pseudoobscura (MV25): pooled brains (replicate 1)
#SRR4416179	D. pseudoobscura: male 3rd instar larva
#SRR4416168	D. pseudoobscura: female 3rd instar larva
#SRR29261110	Drosophila pseudoobscura: ovaries
#SRR6968195
#SRR6968196
#SRR6968197
#SRR6968198
#SRR6968199





: <<'SKIP'
##Isoseq Sample List
SRR11813290     Isoseq  Drosophila_pseudoobscura        adult   female  UCI
SRR11813291     Isoseq  Drosophila_pseudoobscura        adult   mael    UCI


##illumina RNAseq Sample List
ERR15566737	Abdomens from 10 wildtype strain virgin males - replicate 1	
ERR15566738	Abdomens from 10 wildtype strain virgin males - replicate 2
ERR15566739	Abdomens from 10 wildtype strain virgin males - replicate 3
ERR15566740	Abdomens from 10 wildtype strain virgin males - replicate 4
ERR15566719	Female reproductive tracts from 15 wildtype strain virgin females - replicate 2
ERR15566731	Female reproductive tracts from 15 wildtype strain virgin females - replicate 4
ERR15566720	Female reproductive tracts from 15 wildtype strain females mated to wildtype strain males - replicate 2
ERR15566726	Female reproductive tracts from 15 wildtype strain females mated to wildtype strain males - replicate 3
SRR18151013	Young male D. pseudoobscura (MV25): pooled brains (replicate 2)
SRR18151014	Young male D. pseudoobscura (MV25): pooled brains (replicate 1)
SRR4416179	D. pseudoobscura: male 3rd instar larva
SRR4416168	D. pseudoobscura: female 3rd instar larva
SRR29261110	Drosophila pseudoobscura: ovaries
SRR23592633	Dpse.ovary.1; Drosophila pseudoobscura
SRR23592632	Dpse.ovary.2; Drosophila pseudoobscura
SRX5995646	totalRNA-seq of D. pseudoobscura: testes
TRIzol reagent extraction of total RNA from single embryos: 
SRR6968212
SRR6968195
SRR6968196
SRR6968197
SRR6968198
SRR6968199
SRR6968200
SRR6968207
SRR6968208
SRR6968209
SRR6968210
SRR6968211
SKIP