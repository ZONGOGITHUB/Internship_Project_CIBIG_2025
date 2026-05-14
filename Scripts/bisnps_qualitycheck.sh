#!/bin/bash
#SBATCH --job-name=QC_before_filtering
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/qcbf_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/qcbf_%j.err
#SBATCH --partition=normal
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=01:00:00

set -euo pipefail

########################################
# PATHS DIRECTS
########################################

VCF="/scratch/zongo/CIBIG_Internship_Project/Results/SPNcalling/bisnps.vcf.gz"

OUT="/scratch/zongo/CIBIG_Internship_Project/QC_before"

mkdir -p $OUT

########################################
# MODULES
########################################
module purge
module load bioinfo-wave
module load bcftools/1.18
module load vcftools/0.1.16

########################################
# 1. QUAL
########################################

echo "STEP 1 - QUAL"

bcftools query -f '%QUAL\n' $VCF > $OUT/qual.txt

########################################
# 2. DEPTH GLOBAL (INFO/DP)
########################################

echo "STEP 2 - INFO/DP"

bcftools query -f '%INFO/DP\n' $VCF > $OUT/dp.txt

########################################
# 3. MISSING PER SNP
########################################

echo "STEP 3 - Missing per SNP"

vcftools --gzvcf $VCF \
         --missing-site \
         --out $OUT/site_missing

########################################
# 4. MISSING PER INDIVIDUAL
########################################

echo "STEP 4 - Missing per individual"

vcftools --gzvcf $VCF \
         --missing-indv \
         --out $OUT/ind_missing

########################################
# 5. MAF
########################################

echo "STEP 5 - MAF"

vcftools --gzvcf $VCF \
         --freq \
         --out $OUT/maf

########################################
# 6. MEAN DEPTH PER INDIVIDUAL
########################################

echo "STEP 6 - Mean depth per individual"

vcftools --gzvcf $VCF \
         --depth \
         --out $OUT/mean_depth_individual

########################################
# 7. MEAN DEPTH PER SITE
########################################

echo "STEP 7 - Mean depth per site"

vcftools --gzvcf $VCF \
         --site-mean-depth \
         --out $OUT/site_depth

########################################
# 8. TOTAL SNP COUNT
########################################

echo "STEP 8 - SNP count"

bcftools view -H $VCF | wc -l > $OUT/total_snps.txt

########################################
# FIN
########################################

echo "QC FINISHED SUCCESSFULLY"
