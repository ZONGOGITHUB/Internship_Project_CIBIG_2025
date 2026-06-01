#!/bin/bash

set -euo pipefail

module purge
module load bioinfo-wave
module load bcftools/1.18

THREADS=4
VCF=bisnps_clean_names.vcf.gz

echo "=============================="
echo "PIPELINE PCA/DAPC OPTIMISE (BALANCED)"
echo "=============================="

########################################
# STEP 1 - QUAL
########################################
bcftools filter --threads $THREADS -i 'QUAL>=30' $VCF \
  -Oz -o step1.qual.vcf.gz

bcftools index step1.qual.vcf.gz

########################################
# STEP 2 - DP MIN
########################################
bcftools filter --threads $THREADS -i 'INFO/DP>=8' step1.qual.vcf.gz \
  -Oz -o step2.dpmin.vcf.gz

bcftools index step2.dpmin.vcf.gz

########################################
# STEP 3 - DP MAX
########################################
bcftools filter --threads $THREADS -i 'INFO/DP<=400' step2.dpmin.vcf.gz \
  -Oz -o step3.dpmax.vcf.gz

bcftools index step3.dpmax.vcf.gz

########################################
# STEP 4 - MISSING
########################################
bcftools filter --threads $THREADS -e 'F_MISSING>0.5' step3.dpmax.vcf.gz \
  -Oz -o step4.missing.vcf.gz

bcftools index step4.missing.vcf.gz

########################################
# STEP 5 - MAF
########################################
bcftools +fill-tags --threads $THREADS step4.missing.vcf.gz \
  -Oz -o step5.maf.vcf.gz -- -t MAF

bcftools index step5.maf.vcf.gz

bcftools filter --threads $THREADS -e 'MAF<0.01' step5.maf.vcf.gz \
  -Oz -o step6.final.vcf.gz

bcftools index step6.final.vcf.gz

########################################
# STATS
########################################
bcftools stats step6.final.vcf.gz > final_stats.txt

echo "DONE"
