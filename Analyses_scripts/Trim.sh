#!/bin/bash

# Slurm configuration
#SBATCH --job-name=trimmomatic
#SBATCH -p normal
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.err
#SBATCH --nodelist=node02
#SBATCH --array=0-76%4       
#SBATCH -c 4

# Modules loading
module load bioinfo-wave
module load trimmomatic/0.39

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/RAW_DATA"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"

#  R1 et R2 files listes
R1_FILES=("$INPUT_DIR"/*_R1.fastq.gz)
R2_FILES=("$INPUT_DIR"/*_R2.fastq.gz)

# Samples index SLURM

INDEX=$SLURM_ARRAY_TASK_ID
R1=${R1_FILES[$INDEX]}
R2=${R2_FILES[$INDEX]}

if [[ ! -f "$R1" ]] || [[ ! -f "$R2" ]]; then
    echo "Skipping index $INDEX: files missing"
    exit 1
fi

SAMPLE=$(basename "$R1" _R1.fastq.gz)

echo "Processing $SAMPLE ..."

# Trimmomatic PE 
trimmomatic PE -threads 4 -phred33 \
    "$R1" "$R2" \
    "$OUTPUT_DIR/${SAMPLE}_R1_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R1_unpaired.fastq.gz" \
    "$OUTPUT_DIR/${SAMPLE}_R2_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R2_unpaired.fastq.gz" \
    SLIDINGWINDOW:4:30 \
    LEADING:3 TRAILING:3 \
    MINLEN:36

echo "Finished $SAMPLE"
