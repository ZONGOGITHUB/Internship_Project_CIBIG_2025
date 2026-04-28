#!/bin/bash`

# Slurm configuration
#SBATCH --job-name=multiqc
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.err
#SBATCH --nodelist=node02


set -euo pipefail

# Miniforge and MultiQC environment activation

source ~/miniforge3/bin/activate
conda activate multiqc_env

# Directories

Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_results"

mkdir -p "$Multiqc_out" QC/logs

# Multiqc running

multiqc "$Fastqc_dir" -o "$Multiqc_out"
