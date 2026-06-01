#!/bin/bash

set -e

# --- Modules loading ---
echo "=== Configuring Cluster Modules ==="
module purge
module load bioinfo-wave
module load vcftools/0.1.16

# --- Variables ---

INPUT_VCF="bisnps_clean_names.vcf.gz"
OUTPUT_DIR="bisnps_check"

mkdir -p "$OUTPUT_DIR"

echo "=== Starting Quality Control Calculations ==="

# 1. Calculate allele frequency
echo "-> Calculating allele frequencies..."
vcftools --gzvcf "$INPUT_VCF" --freq2 --out "$OUTPUT_DIR/allele_freq"

# 2. Calculate site quality
echo "-> Calculating site quality scores..."
vcftools --gzvcf "$INPUT_VCF" --site-quality --out "$OUTPUT_DIR/qual_site"

# 3. Calculate mean depth per site
echo "-> Calculating mean depth per site..."
vcftools --gzvcf "$INPUT_VCF" --site-mean-depth --out "$OUTPUT_DIR/site_depth"

# 4. Calculate mean depth per individual
echo "-> Calculating depth per individual..."
vcftools --gzvcf "$INPUT_VCF" --depth --out "$OUTPUT_DIR/indiv_depth"

# 5. Calculate proportion of missing data per site
echo "-> Calculating missing data per site..."
vcftools --gzvcf "$INPUT_VCF" --missing-site --out "$OUTPUT_DIR/miss_site"

# 6. Calculate proportion of missing data per individual
echo "-> Calculating missing data per individual..."
vcftools --gzvcf "$INPUT_VCF" --missing-indv --out "$OUTPUT_DIR/miss_indv"

# 7. Calculate heterozygosity and inbreeding coefficient per individual
echo "-> Calculating heterozygosity and inbreeding per individual..."
vcftools --gzvcf "$INPUT_VCF" --het --out "$OUTPUT_DIR/het_indb_individu"

echo "=== Calculations Completed! ==="
echo "All statistics files are saved in: $OUTPUT_DIR"

