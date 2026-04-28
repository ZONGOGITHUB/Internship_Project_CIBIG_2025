#!/bin/bash
#SBATCH --job-name=multiqc_trim
#SBATCH --partition=normal
#SBATCH --nodelist=node02
#SBATCH -c 2
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_trim_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_trim_%j.err

set -euo pipefail

source ~/miniforge3/bin/activate
conda activate multiqc_env

Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_trim_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_trim_results"

mkdir -p "$Multiqc_out"

multiqc "$Fastqc_dir" -o "$Multiqc_out"
