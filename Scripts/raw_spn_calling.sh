#!/bin/bash

#SBATCH --job-name=raw_snpcalling
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/rawsnp_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/rawsnp_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# ===================== MODULES TO LOAD =====================
module load bioinfo-wave
module load bcftools/1.18

# ===================== PATHS =====================

OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/SNP_calling"

RAW_VCF="$OUTPUT_DIR/all_samples.raw.vcf.gz"

RAW_SNP_VCF="$OUTPUT_DIR/all_samples_rawsnp.vcf.gz"

RAW_SNP_STATS_FILE="$OUTPUT_DIR/all_samples_rawsnp_stats.txt"

# ===================== FILTER RAW SNPs =====================

echo "Filtering RAW SNPs..."

bcftools view \
    -v snps \
    -Oz \
    -o "$RAW_SNP_VCF" \
    "$RAW_VCF"

# ===================== INDEX =====================

echo "Indexing VCF..."

bcftools index "$RAW_SNP_VCF"

# ===================== SNP STATS =====================

echo "Generating SNP statistics..."

bcftools stats \
    "$RAW_SNP_VCF" > "$RAW_SNP_STATS_FILE"

echo "Pipeline completed successfully."
