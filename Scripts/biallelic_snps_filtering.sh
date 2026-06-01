#!/bin/bash

set -euo pipefail

module purge
module load bioinfo-wave
module load bcftools/1.18

THREADS=4
VCF=bisnps_clean_names.vcf.gz



# STEP 1 - QUAL
bcftools filter --threads $THREADS -i 'QUAL>=30' $VCF \
  -Oz -o step1.qual.vcf.gz

bcftools index step1.qual.vcf.gz


# STEP 2 - DP MIN
bcftools filter --threads $THREADS -i 'INFO/DP>=8' step1.qual.vcf.gz \
  -Oz -o step2.dpmin.vcf.gz

bcftools index step2.dpmin.vcf.gz


# STEP 3 - DP MAX
bcftools filter --threads $THREADS -i 'INFO/DP<=400' step2.dpmin.vcf.gz \
  -Oz -o step3.dpmax.vcf.gz

bcftools index step3.dpmax.vcf.gz

# STEP 4 - MISSING
bcftools filter --threads $THREADS -e 'F_MISSING>0.5' step3.dpmax.vcf.gz \
  -Oz -o step4.missing.vcf.gz

bcftools index step4.missing.vcf.gz

# STEP 5 - MAF
bcftools +fill-tags --threads $THREADS step4.missing.vcf.gz \
  -Oz -o step5.maf.vcf.gz -- -t MAF

bcftools index step5.maf.vcf.gz

bcftools filter --threads $THREADS -e 'MAF<0.01' step5.maf.vcf.gz \
  -Oz -o filtered_bisnps.vcf.gz

bcftools index filtered_bisnps.vcf.gz

# STATS
bcftools stats filtered_bisnps.vcf.gz > filtered_bisnsps_stats.txt

echo "DONE"
