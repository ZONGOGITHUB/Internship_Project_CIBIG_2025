#!/bin/bash
#------Slurm configuration------
#SBATCH --job-name=fastqc_trimmed
#SBATCH -p normal
#SBATCH -c 12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_trimmed_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_trimmed_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Modules loading
module load bioinfo-wave
module load fastqc/0.12.1

# Directories
Input_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/Trimmomatic"
Output_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc_trimmed"

mkdir -p "$Output_dir"

# Loop on R1 files
for R1 in "$Input_dir"/*_R1_paired.fastq.gz; do
    base=$(basename "$R1" _R1_paired.fastq.gz)
    R2="$Input_dir/${base}_R2_paired.fastq.gz"

  # R2 files checking
    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for: $base"
        continue
    fi

    echo "Processing trimmed sample: $base"

# Fastqc running
    fastqc --threads 12 -o "$Output_dir" "$R1" "$R2"
done
