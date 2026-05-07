#!/bin/bash
#----Slurm configuration----
#SBATCH --job-name=trimmomatic
#SBATCH -p normal
#SBATCH -c 12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/trimmomatic_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/trimmomatic_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Modules loading
module load bioinfo-wave
module load trimmomatic/0.39

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Data"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/QC/Trimmomatic"

mkdir -p "$OUTPUT_DIR"

# Loop on R1 files
for R1 in "$INPUT_DIR"/*_R1.fastq.gz; do
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="$INPUT_DIR/${SAMPLE}_R2.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for: $SAMPLE"
        continue
    fi

    echo "Processing $SAMPLE ..."

# Trimmomatic running
    trimmomatic PE -phred33 -threads 12 \
        "$R1" "$R2" \
        "$OUTPUT_DIR/${SAMPLE}_R1_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R1_unpaired.fastq.gz" \
        "$OUTPUT_DIR/${SAMPLE}_R2_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R2_unpaired.fastq.gz" \
        SLIDINGWINDOW:4:20 MINLEN:50
done
