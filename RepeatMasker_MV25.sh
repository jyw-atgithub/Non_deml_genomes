#!/bin/bash
#SBATCH --job-name=repeat_masking
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
#SBATCH --cpus-per-task=48
#SBATCH --output="mv25-repeat-masking.out"

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
repeat="/dfs7/jje/jenyuw/Non_melanogaster/repeat"

cd ${repeat}
module load singularity/3.11.3

## Reference: https://github.com/Dfam-consortium/TETools

#singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest

# Use the polished hap1!
target="${prim}/dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fa"


####################### Perform de novo repeat annotation and masking #######################
# this step is fast
singularity exec dfam-tetools-latest.sif BuildDatabase -name Dpse_MV25_DB ${target}
# This step is very slow.
singularity exec dfam-tetools-latest.sif RepeatModeler -database "Dpse_MV25_DB" -threads $SLURM_CPUS_PER_TASK -LTRStruct

# option "-species" and "-lib" are mutually exclusive. 
singularity exec --env LIBDIR=/opt/RepeatMasker/Libraries \
-B ${repeat}/Libraries:/opt/RepeatMasker/Libraries \
-B ${repeat}:/work \
dfam-tetools-latest.sif RepeatMasker -xsmall -s -gccalc -poly \
-pa $SLURM_CPUS_PER_TASK \
-lib ${repeat}/Dpse_MV25_DB-families.fa \
-html -gff -a -dir ${repeat}/MV25-RepeatMasker-lib-output ${target}

####################### Use existing FamDb library #######################
# Use famdb.py to check the manes in FamDB
# 7215 is the NCBI taxon ID for Drosophila
# singularity exec --env LIBDIR=/opt/RepeatMasker/Libraries -B ${repeat}/Libraries:/opt/RepeatMasker/Libraries -B ${repeat}:/work dfam-tetools-latest.sif famdb.py lineage -ad 7215
# --> This shows that Drosophila belongs to Partition 1

# We need to add the FamDB library. Drosophila (Diptera) belongs to  Partition 1 [dfam39_full.1.h5]: Brachycera
# NOT Partition 14 [dfam39_full.14.h5]: Endopterygota (also known as Holometabola)!!

#singularity exec dfam-tetools-latest.sif cp -r /opt/RepeatMasker/Libraries /dfs7/jje/jenyuw/Non_melanogaster/repeat
# Move the .h5 file to Libraries/famdb
#mv FamDB_download/dfam39_full.1.h5 Libraries/famdb/

##### Regenerate the RepeatMasker Libraries ####
# in interactive mode:
#singularity run -B /dfs7/jje/jenyuw/Non_melanogaster/repeat/Libraries:/opt/RepeatMasker/Libraries dfam-tetools-latest.sif
#cd /opt/RepeatMasker
#rm ./Libraries/famdb/rmlib.config
#./tetoolsDfamUpdate.pl

singularity exec --env LIBDIR=/opt/RepeatMasker/Libraries \
-B ${repeat}/Libraries:/opt/RepeatMasker/Libraries \
-B ${repeat}:/work \
dfam-tetools-latest.sif RepeatMasker -xsmall -s -gccalc -poly \
-pa $SLURM_CPUS_PER_TASK \
-species "Drosophila_flies_genus"  \
-html -gff -a -dir ${repeat}/MV25-RepeatMasker-species-output ${target}



# -B WORKING_DIR="/dfs7/jje/jenyuw/Non_melanogaster/repeat"
#SIF="${WORKING_DIR}/tetools_latest.sif"
#LOCAL_LIB="${WORKING_DIR}/Libraries"
#--env LIBDIR=/opt/RepeatMasker/Libraries \
#-B ${LOCAL_LIB}:/opt/RepeatMasker/Libraries \
#-B ${WORKING_DIR}:/work \