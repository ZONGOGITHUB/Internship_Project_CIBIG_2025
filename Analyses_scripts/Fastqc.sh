#!/bin/bash

# Slurm configuration
#SBATCH --job-name=fastqc
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --array=0-76%4
#SBATCH --output=QC/logs/fastqc_%A_%a.out
#SBATCH --error=QC/logs/fastqc_%A_%a.err

# Module loading
module load bioinfo-wave
module load fastqc/0.12.1

# Directories
Input_dir="RAW_DATA"
Output_dir="QC/fastqc_results"
Threads=4

mkdir -p "$Output_dir" QC/logs

# R1 files list
samples=("$Input_dir"/*_R1.fastq.gz)
sample="${samples[$SLURM_ARRAY_TASK_ID]}"
base=$(basename "$sample" _R1.fastq.gz)

R1="$Input_dir/${base}_R1.fastq.gz"
R2="$Input_dir/${base}_R2.fastq.gz"

# R2 files checking
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
   echo "Missing pair: $base"
   exit 1
fi

echo "Processing sample: $base"

# Fastqc running
fastqc -t "$Threads" -o "$Output_dir" "$R1" "$R2"
