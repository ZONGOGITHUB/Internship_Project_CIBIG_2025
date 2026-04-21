#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --array=0-76%4
#SBATCH --output=QC/logs/fastqc_%A_%a.out
#SBATCH --error=QC/logs/fastqc_%A_%a.err
#SBATCH --nodelist=node02

module load bioinfo-wave
module load fastqc/0.12.1

Input_dir="RAW_DATA"
Output_dir="QC/fastqc_results"

mkdir -p "$Output_dir" QC/logs

# Liste des fichiers R1
samples=("$Input_dir"/*_R1.fastq.gz)
sample="${samples[$SLURM_ARRAY_TASK_ID]}"
base=$(basename "$sample" _R1.fastq.gz)

R1="$Input_dir/${base}_R1.fastq.gz"
R2="$Input_dir/${base}_R2.fastq.gz"

# Vérification de la paire
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "Missing pair: $base"
    exit 1
fi

echo "Processing sample: $base"

# Lancer FastQC directement dans Output_dir
fastqc -threads 4 -o "$Output_dir" "$R1" "$R2"
