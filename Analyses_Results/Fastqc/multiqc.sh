#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH -p normal
#SBATCH -c 8
#SBATCH --output=QC/logs/multiqc_%j.out
#SBATCH --error=QC/logs/multiqc_%j.err

module load bioinfo-wave
module load multiqc/1.9

Fastqc_dir="QC/fastqc_results"
Multiqc_out="QC/multiqc_results"

mkdir -p "$Multiqc_out" QC/logs

multiqc "$Fastqc_dir" -o "$Multiqc_out" --threads 8
