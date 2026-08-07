#!/bin/bash
#SBATCH --job-name=aligner
#SBATCH -A jje_lab
#SBATCH -p standard
#SBATCH --mem-per-cpu=6G
###SBATCH --constraint=nvme
#SBATCH --cpus-per-task=50
#SBATCH --output="dorado_polish_aligner_MV25.out"

prim="/dfs7/jje/jenyuw/Non_melanogaster/primary_asm"
mapping="/dfs7/jje/jenyuw/Non_melanogaster/mapping"
polishing="/dfs7/jje/jenyuw/Non_melanogaster/polishing_asm"

target="${prim}/Dpse_MV25_12-2.BOTH_haps.fasta.gz"

raw_reads_dir="/dfs7/jje/jenyuw/Non_melanogaster/raw/Dpse_MV25_for_polishing"

dorado aligner -v --mm2-opts "-x lr:hqae" -t $(($SLURM_CPUS_PER_TASK - 4 )) ${target} ${raw_reads_dir} |\
samtools sort -m 2G -@ 4 -o ${mapping}/dorado-aligner_reads-hifiasm_12-2.BOTH_haps.sorted.bam
samtools index -@ $SLURM_CPUS_PER_TASK ${mapping}/dorado-aligner_reads-hifiasm_12-2.BOTH_haps.sorted.bam
# --> This created many reads of MAPQ=0 because there are two locations can be mapped equally well.
# --> Only work on the hap1.

target="${prim}/Dpse_MV25_12-2.bp.hap1.p_ctg.fasta.gz"
dorado aligner -v --mm2-opts "-x lr:hqae" -t $(($SLURM_CPUS_PER_TASK - 4 )) ${target} ${raw_reads_dir} |\
samtools sort -m 2G -@ 4 -o ${mapping}/dorado-aligner_reads_MV25_12-2.hap1.sorted.bam
samtools index -@ $SLURM_CPUS_PER_TASK ${mapping}/dorado-aligner_reads_MV25_12-2.hap1.sorted.bam




## Performing basecalling again make it much easier
: <<'END'
#We need the SIMPLEX reads in bam format also remove short reads. Do the following on our local machine, e.g.:
#cd /mnt/e/ONT_LSK114_2026/Dpse_MV25_40k/basecalling_Dorado
#samtools view -@ 24 -bh -d dx:0 -d dx:-1 -e 'length(seq) > 20000' Dpse_40k_duplex_Q10_5mC_5hmC_6mA.bam -o Dpse_40k_simplex_only_20kb_Q10_5mC_5hmC_6mA.bam
#cd /mnt/e/ONT_LSK114_2026/Dpse_MV25_SFE_double/basecalling_Dorado
#samtools view -@ 24 -bh -d dx:0 -d dx:-1 -e 'length(seq) > 20000' Dpse_MV25_SFE_double_duplex_Q10_5mC_5hmC_6mA.bam -o Dpse_MV25_SFE_double_simplex_only_20kb_Q10_5mC_5hmC_6mA.bam

#It's already confirmed that lr:hqae works much better than lr:hq!!!

reads_dir="/dfs7/jje/jenyuw/Non_melanogaster/filtered/Dpse_MV25_bamfiles"

dorado aligner -v --mm2-opts "-x lr:hqae" -t $(($SLURM_CPUS_PER_TASK - 4 )) ${target} ${reads_dir} |\
samtools sort -m 2G -@ 4 -o ${mapping}/dorado-aligner_reads-hifiasm_8.sorted.bam

#gawk '{print $25}' to check the RG tag
#replace the RG tag. Its a temporary solution.
#Method 1 -->failed. Probably because the headers were not modified. It was also very slow.
#samtools view -h -@ 8 ${mapping}/dorado-aligner_reads-hifiasm_8.sorted.bam | sed s/"RG:Z:.*\t"/"RG:Z:93522f0a-615d-4fa5-a962-5559a359828b_dna_r10.4.1_e8.2_400bps_sup@v5.2.0\t"/g | samtools view -@ 8 -bh > ${mapping}/dorado-aligner_reads-hifiasm_8.new-rg.bam
#Method 2
samtools addreplacerg -@ 24 -w -r "@RG\tID:2f5af5ec-6cb3-4acc-8997-3765a19e50c0_dna_r10.4.1_e8.2_400bps_sup@v5.2.0\tPU:PBE62703\tPM:DESKTOP-SJ50GEH\tDT:2026-01-29T02:43:09.249000+00:00\tPL:ONT\tDS:runid=2f5af5ec-6cb3-4acc-8997-3765a19e50c0 basecall_model=dna_r10.4.1_e8.2_400bps_sup@v5.2.0\tLB:Dpse_MV25_40k" \
${mapping}/dorado-aligner_reads-hifiasm_8.sorted.bam -o ${mapping}/dorado-aligner_reads-hifiasm_8.new-rg.bam

#Method 3: just remove the RG tags of duplex reads? although they had been filtered out.
#grep -v "dna_r10.4.1_e8.2_5khz_stereo@v1.4"
#and then 
#dorado polish --ignore-read-groups 

samtools index -@ 24 ${mapping}/dorado-aligner_reads-hifiasm_8.new-rg.bam

#output fastQ
dorado polish --device "cpu" --qualities ${mapping}/dorado-aligner_reads-hifiasm_8.new-rg.bam ${target} |\
bgzip -@ 2 -c >${polishing}/dorado-ploished_Dpse_MV25_hifiasm_8.fastq.gz

#Input BAM file has a mix of different basecaller models. Only one basecaller model can be processed. List of all basecaller models found in the BAM file: dna_r10.4.1_e8.2_400bps_sup@v5.2.0, dna_r10.4.1_e8.2_400bps_sup@v5.2.0_dna_r10.4.1_e8.2_5khz_stereo@v1.4

END