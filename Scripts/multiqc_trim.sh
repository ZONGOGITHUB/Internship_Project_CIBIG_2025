#!/bin/bash
#----Slurm configuration----
#SBATCH --job-name=multiqc_trimmed
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/multiqc_trimmed_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/multiqc_trimmed_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Miniforge and MultiQC activating
source ~/miniforge3/bin/activate
conda activate multiqc_env

# Directories
Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc_trimmed"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/Results/QC/multiqc_trimmed"

mkdir -p "$Multiqc_out"

# MultiQC running
multiqc "$Fastqc_dir" -o "$Multiqc_out"
