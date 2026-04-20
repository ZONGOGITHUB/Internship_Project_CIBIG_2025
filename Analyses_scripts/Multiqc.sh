#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Activation de Miniforge et de l'environnement MultiQC

source ~/miniforge3/bin/activate
conda activate multiqc_env

# Définition des répertoires

Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_results"

mkdir -p "$Multiqc_out" QC/logs

# Lancement de  MultiQC depuis l'environnement Miniforge

multiqc "$Fastqc_dir" -o "$Multiqc_out"
