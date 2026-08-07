#!/bin/bash

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
busco_out="/dfs7/jje/jenyuw/Non_melanogaster/busco_out"


micromamba activate BUSCOv6
##Remember to request enough memory with slurm
export _JAVA_OPTIONS="-Xmx240g"

cd ${busco_out}
target="Dpse_MV25_12-2.bp.hap1.p_ctg.fasta"
## busco V6.0.0 was released with orthodb v12
busco -i ${target} -m "genome" -l "drosophila_odb12" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_12-2_hap1" -f
busco -i ${target} -m "genome" -l "drosophila_odb12.2" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_12-2_hap1-odb122"
busco -i ${target} -m "genome" -l "diptera_odb12" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_12-2_hap1_deptera"
busco -i /dfs7/jje/jenyuw/Assembling_ISO1/results/assembly/hifiasm_011/011.p_ctg.fasta.gz -m "genome" -l "drosophila_odb12" -c $SLURM_CPUS_PER_TASK -o "busco_hifiasm_011"


## Below analysis was done when busco V6.1.0 was released (with orthodb v12.2)
#busco --list-datasets odb12.2
target="Dpse_MV25_12-2.bp.hap1.p_ctg.fasta"
busco -i ${target} -m "genome" -l "drosophila_odb12.2" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_12-2_hap1-odb122"

target="${prim}/dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fasta.PolcaCorrected.fa"
busco -i ${target} -m "genome" -l "drosophila_odb12.2" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_hap1_polished"

prot_target="/dfs7/jje/jenyuw/Non_melanogaster/EGAPX_annotation/a1/b514cc3a8125f772a408af3674d151/EGAPx_Test_Assembly_EGAPx_Test_Assembly.prot.fa"
# Don't use the resulted protein sequences (complete.proteins.faa) because it contains alternative transcripts
# Go to the automatic busco output folder and find the file name in the short_summary.......txt
busco -i ${prot_target} -m "proteins" -l "drosophila_odb12.2" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_hap1_polished_EGAPX"

prot_target="/dfs7/jje/jenyuw/Non_melanogaster/BRAKER4_annotation/BRAKER4/output/mv25/results/braker.longest.aa.gz"
busco -i ${prot_target} -m "proteins" -l "drosophila_odb12.2" -c $SLURM_CPUS_PER_TASK -o "busco_Dpse_MV25_hap1_polished_BRAKER4" -f

micromamba deactivate