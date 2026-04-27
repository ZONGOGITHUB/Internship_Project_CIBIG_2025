#!/bin/bash
#SBATCH --job-name=fastqc_trim
#SBATCH --exclude=node01,node03,node05,node06
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/fastqc_trim.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/fastqc_trim.err

module load bioinfo-wave
module load fastqc/0.12.1

INPUT="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"
OUTPUT="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_trim_results"

mkdir -p "$OUTPUT"

echo "FastQC en cours..."


find "$INPUT" -name "*_R1_paired.fastq.gz" | xargs -n 1 -P 2 bash -c '
R1="$1"
R2="${R1/_R1_/_R2_}"
[[ -f "$R2" ]] || exit
fastqc -threads 4 -o "'"$OUTPUT"'" "$R1" "$R2"
' _
