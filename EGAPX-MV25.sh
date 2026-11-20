#!/bin/bash
#SBATCH --job-name=mv25-egapx
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=28
#SBATCH --mem-per-cpu=6G
#SBATCH --constraint=nvme
#SBATCH --tmp=200GB


module load python/3.14.3
## This is the older version: the directory was renamed as /dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx_v1
## source /dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx/egapx_venv_2/bin/activate
source /dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx/EGAPX_venv/bin/activate
EGAPX="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx/ui/egapx.py"

# Run EGAPx for the first time to generate the config files so you can edit them:
#python3 "$EGAPX" ./egapx/examples/input_D_farinae_small.yaml -e slurm -w $PWD -o test

## The congifure files under /dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx_config:
# "process_resources.config" and "slurm.config" need to be modified accordingly.
## nf/bin/run_wnode_batch.py was edited according to the issue ##248 on Github (https://github.com/ncbi/egapx/issues/248)

config_dir="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx_config"
work_dir="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation"
cd "${work_dir}"

module load singularity/3.11.3
export NXF_VER=23.10.1 # This is the required version. The latest version of Nextflow causes error.
export SINGULARITY_BINDPATH="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/"


## Offline mode.
## Download required data first.
python3 "$EGAPX" egapx_runinfo.MV25_OFFLINE.yaml -dl -lc ${work_dir}/egapx_local_cache
## Perform the annotation.
python3 "$EGAPX" egapx_runinfo.MV25_OFFLINE.yaml -lc ${work_dir}/egapx_local_cache \
--config-dir "${config_dir}" -e slurm -w "${work_dir}" -o MV25_egapx_final

## Online mode.
## Sometimes ftp failed. --> clearing your Nextflow execution cache via nextflow clean or rm -rf .nextflow* before a rerun often bypasses a temporary network glitch
## Error keeps happening after switching to version 1.0.1. It has been reported on GitHub (https://github.com/ncbi/egapx/issues/278)
python3 "$EGAPX" egapx_runinfo.MV25.yaml --config-dir "${config_dir}" -e slurm -w "${work_dir}" -o MV25_egapx_final
#-resume -o MV25_egapx

deactivate

