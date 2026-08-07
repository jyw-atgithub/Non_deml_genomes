#!/bin/bash

#SBATCH --job-name=mv25-egapx
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --array=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=6G


module load python/3.14.3

## python venv: egapx_venv_2
source /dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/egapx/egapx_venv_2/bin/activate
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
# This is the required version. The latest version of Nextflow causes error.
export NXF_VER=23.10.1
#python3 "$EGAPX" P_chirus_egapx_config.yaml --config-dir "${config_dir}" -e slurm -w "${work_dir}" -o PC

python3 "$EGAPX" egapx_runinfo.MV25.yaml --config-dir "${config_dir}" -e slurm -w "${work_dir}" -o MV25_egapx
#-resume

deactivate


