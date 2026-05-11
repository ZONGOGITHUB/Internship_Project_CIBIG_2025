#!/bin/bash

#SBATCH --job-name=snpcalling
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/snp_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/snp_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# ===================== MODULES TO LOAD =====================
module load bioinfo-wave
module load bcftools/1.18

# ===================== PATHS =====================
BAM_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping_sorted"
REF="/scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/SNP_calling"

mkdir -p "$OUTPUT_DIR"

# ===================== OUTPUT FILES =====================
RAW_VCF="$OUTPUT_DIR/all_samples.raw.vcf.gz"
SNP_VCF="$OUTPUT_DIR/all_samples_snp.vcf.gz"
SNP_STATS_FILE="$OUTPUT_DIR/all_samples_snp_stats.txt"

# ===================== SNP CALLING =====================
bcftools mpileup --threads 12 -Ou -f "$REF" "$BAM_DIR"/*_sorted.bam | \
bcftools call -mv -Oz -o "$RAW_VCF"

bcftools index "$RAW_VCF"

# ===================== RAW_VCF FILTERING TO RETAIN ONLY BIALLELIC SNP =====================
echo "Filtering biallelic SNPs..."

bcftools view \
    -m2 -M2 \
    -v snps \ 
    -Oz \
    -o "$SNP_VCF" \
    "$RAW_VCF"

bcftools index "$SNP_VCF"

# ===================== SNP STATS =====================
echo "Generating SNP statistics..."

bcftools stats "$SNP_VCF" > "$SNP_STATS_FILE"

echo "Pipeline completed successfully."
