# Internship_Project_CIBIG_2025

# TOPIC:  Genetic structure study of _Magnaporthe oryzae_ population

### Lignées spécifiques de _Magnaporthe oryzae_
L’étude des structures génétiques des populations pathogènes, en lien avec des traits d'histoire de vie tels que le mode de reproduction, l'étendue des hôtes ou la résistance aux traitements, est essentielle pour comprendre l'émergence et la propagation des maladies infectieuses. Parmi les pathogènes des plantes, le champignon ascomycète _Magnaporthe oryzae_, responsable de la maladie du "blast" sur de nombreuses espèces de graminées cultivées et sauvages, constitue un modèle d'intérêt. Bien que ce pathogène soit principalement étudié pour ses effets dévastateurs sur le riz (_Oryza sativa_), il infecte également d'autres cultures céréalières, telles que le blé, l'orge et le millet, ainsi que des graminées comme le ray-grass et l'herbe de Saint-Augustin. 
Les recherches antérieures ont montré que _M. oryzae_ est subdivisé en plusieurs lignées spécifiques à leurs hôtes, avec une divergence génétique probablement liée aux changements d'hôtes. 
Cette étude vise à approfondir la compréhension de la structure génétique de plusieurs isolats de _Magnaporthe_ (voir tableau), issus de différentes espèces hôtes, pour déterminer s'ils forment des lignées hôtes-spécifiques et évaluer l'existence d'espèces cryptiques au sein de _M. oryzae_. 
En bref:

On cherche à comprendre la structure des populations de _M. oryzae_
1) Quel est le lien entre l'hôte et la structuration de la population?
2) Y a t-il des espèces cryptiques qui se détachent du reste de la population  de _M. oryzae_ ou bien _M. oryzae_ n’est constitué que d’une seule espèce, indépendamment de son hôte?
    


# SUPERVISORS
    
# Institutional supervisor: Prof Fidèle TIENDREBEOGO (WAVE)

# Academic supervisors: Sébastien RAVEL (CIRAD) and Christine Tranchant-Dubreuil (IRD)


# I. BIOINFORMATIC STRATEGY
# 1. Project Mind Map: 
Access link: https://mm.tt/map/3944152256?t=KJA8lJE8Ul


## 2. SEQUENCING DATA ACQUISITION
   
## 2.1. Connecting to NCBI and EMBL-EBI
https://www.ncbi.nlm.nih.gov/
https://www.ebi.ac.uk/ena/browser/home

## 2.2. Connecting to WAVE cluster and moving to my working directory
```bash
ssh login@160.120.108.164
srun -c 2 -p short --nodelist=node02 --pty bash -i
cd /scratch/username/
```

## 2.3. Creating of my working directory and raw data sub-directory in /scratch/zongo
```bash
mkdir -p CIBIG_2025_Internship_Project/Data
```

## 2.4. Data downloading in RAW_DATA directory from NCBI and EMBL-EBI using Isolate ID and Projects accesions
```bash
wget https:"IsolateID_R1.fastq.gz accesslink" https:"IsolateID_R2.fastq.gz accesslink"
```

## 2.5. Files renaming with R1 and R2
```bash
for f in *.fastq.gz; do
    new=$(echo "$f" | sed -E 's/_1\.fastq\.gz$/_R1.fastq.gz/; s/_2\.fastq\.gz$/_R2.fastq.gz/')

    if [ "$f" != "$new" ]; then
        mv -i "$f" "$new"
        echo "$f -> $new"
    fi
done
```


# 3. DATA ANALYSES

## 3.1. Quality control
## 3.1.1. Creating a directory QC and subdirectories fastqc and multiqc
```bash
mkdir -p Results/QC/fastqc Results/QC/multiqc
```

### 3.1.2.Fastqc
```bash
#!/bin/bash
#------Slurm configuration------
#SBATCH --job-name=fastqc
#SBATCH -p normal
#SBATCH -c 8
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_%A_%a.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_%A_%a.err
#SBATCH --nodelist=node02

# Modules loading
module load bioinfo-wave
module load fastqc/0.12.1

# Directories
Input_dir="/scratch/zongo/CIBIG_Internship_Project/Data"
Output_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc"

mkdir -p "$Output_dir"

# Loop on R1 files
for R1 in "$Input_dir"/*_R1.fastq.gz; do
    base=$(basename "$R1" _R1.fastq.gz)
    R2="$Input_dir/${base}_R2.fastq.gz"

    # R2 files checking
    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for: $base"
        continue
    fi

    echo "Processing sample: $base"

# Fastqc running

    fastqc --threads 8 -o "$Output_dir" "$R1" "$R2"
done
```

### 3.1.3. Copying fastqc results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc .
```

### 3.1.4. MultiQC
### 3.1.5. Multiqc 1.13 installing using Miniforge
      
```bash
#!/bin/bash

#  Miniforge x86_64 downloading

wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/Miniforge3-Linux-x86_64.sh

# Making the script executable
chmod +x ~/Miniforge3-Linux-x86_64.sh

# Installation running
# Enter 'yes'
~/Miniforge3-Linux-x86_64.sh

# Miniforge activation
source ~/miniforge3/bin/activate

# Conda updating
conda update -n base -c defaults conda -y

# MultiQC environment creation
conda create -n multiqc_env python=3.8 -y
conda activate multiqc_env

#  MultiQC 1.13 installing
conda install -c bioconda multiqc=1.13 -y
```

### 3.1.6. Multiqc script
```bash
#!/bin/bash
#----Slurm configuration----
#SBATCH --job-name=multiqc
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12 
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/multiqc_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/multiqc_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Miniforge and MultiQC activating
source ~/miniforge3/bin/activate
conda activate multiqc_env

# Directories
Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/Results/QC/multiqc"

mkdir -p "$Multiqc_out"

# MultiQC running
multiqc "$Fastqc_dir" -o "$Multiqc_out"
```

### 3.1.7. Copying multiqc results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/multiqc/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/multiqc .
```


### 3.2. TRIMMING
```bash
#!/bin/bash
#----Slurm configuration----
#SBATCH --job-name=trimmomatic
#SBATCH -p normal
#SBATCH -c 12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/trimmomatic_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/trimmomatic_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Modules loading
module load bioinfo-wave
module load trimmomatic/0.39

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Data"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/QC/Trimmomatic"

mkdir -p "$OUTPUT_DIR"

# Loop on R1 files
for R1 in "$INPUT_DIR"/*_R1.fastq.gz; do
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="$INPUT_DIR/${SAMPLE}_R2.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for: $SAMPLE"
        continue
    fi

    echo "Processing $SAMPLE ..."
# Trimmomatic running
    trimmomatic PE -phred33 -threads 12 \
        "$R1" "$R2" \
        "$OUTPUT_DIR/${SAMPLE}_R1_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R1_unpaired.fastq.gz" \
        "$OUTPUT_DIR/${SAMPLE}_R2_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R2_unpaired.fastq.gz" \
        SLIDINGWINDOW:4:20 MINLEN:50
done
```

### 3.3. Fastqc on trimmed data
```bash
#!/bin/bash
#------Slurm configuration------
#SBATCH --job-name=fastqc_trimmed
#SBATCH -p normal
#SBATCH -c 12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_trimmed_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/fastqc_trimmed_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Modules loading
module load bioinfo-wave
module load fastqc/0.12.1

# Directories
Input_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/Trimmomatic"
Output_dir="/scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc_trimmed"

mkdir -p "$Output_dir"

# Loop on R1 files
for R1 in "$Input_dir"/*_R1_paired.fastq.gz; do
    base=$(basename "$R1" _R1_paired.fastq.gz)
    R2="$Input_dir/${base}_R2_paired.fastq.gz"

  # R2 files checking
    if [[ ! -f "$R2" ]]; then
        echo "Missing pair for: $base"
        continue
    fi

    echo "Processing trimmed sample: $base"

# Fastqc running
    fastqc --threads 12 -o "$Output_dir" "$R1" "$R2"
done
```

### 3.4. Copying fastqc_trimmed results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc_trimmed/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc_trimmed .
```


### 3.5. Multiqc on trimmed data
```bash
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
```

### 3.4. Copying fastqc_trimmed results on my gitclone
```bash
scp -r /scratch/user/CIBIG_Internship_Project/Results/QC/multiqc_trimmed/ /home/user/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/multiqc_trimmed .
```


### 3.5. MAPPING 
```bash
#!/bin/bash

# Slurm configuration
#SBATCH --job-name=mapping
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/mapping_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/mapping_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/QC/Trimmomatic"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping"
REF_GENOME="/scratch/zongo/CIBIG_Internship_Project/Ref/GCF_000002495.2_MG8_genomic.fna"

mkdir -p "$OUTPUT_DIR"

# Modules loading
module load bioinfo-wave
module load bwamem2/2.3
module load samtools/1.23.1

# Ref genome indexing
if [[ ! -f "${REF_GENOME}.bwt.2bit.64" ]]; then
    echo "Index BWA inexistant, création en cours..."
    bwa-mem2 index "$REF_GENOME"
    echo "Index créé."
else
    echo "Index BWA trouvé, utilisation de l'existant."
fi
# Loop on the sequences
for R1 in "$INPUT_DIR"/*_R1_paired.fastq.gz; do

    # Samples name from R1
    sample=$(basename "$R1" _R1_paired.fastq.gz)
    # Construction du chemin du fichier R2 correspondant
    R2="$INPUT_DIR/${sample}_R2_paired.fastq.gz"

    # Output directories
    BAM_FILE="$OUTPUT_DIR/${sample}.bam"
    STATS_FILE="$OUTPUT_DIR/${sample}_stats.txt"
    FILTERED_FILE="$OUTPUT_DIR/${sample}_filtered.bam"
    SORTED_FILE="$OUTPUT_DIR/${sample}_sorted.bam"

    # Mapping
    bwa-mem2 mem -t 12 "$REF_GENOME" "$R1" "$R2" | samtools view -@ 12 -Sb - > "$BAM_FILE"

    # Bam statistics
    samtools flagstat "$BAM_FILE" > "$STATS_FILE"

    # Bam filtering
    samtools view -b -q 30 "$BAM_FILE" > "$FILTERED_FILE"
    rm -f "$BAM_FILE"

    # filtered.bam sorting with MAPQ >= 30
    samtools sort -o "$SORTED_FILE" "$FILTERED_FILE"
    rm -f "$FILTERED_FILE"

    # Sorted.bam indexing
    samtools index "$SORTED_FILE"

    echo "✅ Terminé pour $sample"
done
```

### 3.4. Copying Mapping_results on my computer
```bash
[zongo@node02 ~]$ scp -r /scratch/zongo/CIBIG_Internship_Project/Mapping/ /home/zongo/
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/Mapping .
```

### 3.5. SNP CALLING
#### 3.5.1 Reference genome indexing
```bash
module load bioinfo_wave
module load samtools/1.23.1
samtools faidx /scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna
```
#### 3.5.2 RAW snps obtainining

```bash
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
```
### Biallelic snps obtaining 
```bash
bcftools view --threads 8 -m2 -M2 -v snps all_samples_rawsnp.vcf.gz -Oz -o all_samples_biallelic_snps.vcf.gz
bcftools stats all_samples_biallelic_snps.vcf.gz > all_samples_biallelic_snp_stats.txt
```

### Biallelic snps parameters statistics checking

```bash
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
```
### Biallelic snps parameters plotting in R
```bash
# ==============================================================================
# 1. AUTOMATIC PACKAGE INSTALLATION AND LIBRARY LOADING
# ==============================================================================
required_packages <- c("tidyverse", "gridExtra")

# Installation automatique des packages manquants si internet est disponible
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://r-project.org")

# Chargement des librairies
library(tidyverse)
library(gridExtra)

# Définition du dossier contenant vos outputs VCFTools
data_dir <- "bisnps_check"

print("=== Starting VCF QC Density Visualization ===")

# Initialisation des variables à NULL pour empêcher les plantages
p1 <- p2 <- p3 <- p4 <- p5 <- NULL

# Configuration des paramètres esthétiques communs (Style exact de votre image)
fill_color  <- "#bcdffc"
line_color  <- "black"
line_weight <- 1.2

# ==============================================================================
# 2. SITE QUALITY PLOT (QUAL) - PLOT 1/5
# ==============================================================================
qual_file <- file.path(data_dir, "qual_site.lqual")
if(file.exists(qual_file)) {
  qual_data <- read_table(qual_file, col_types = cols())
  
  p1 <- ggplot(qual_data, aes(x = QUAL)) +
    geom_density(fill = fill_color, color = line_color, linewidth = line_weight, alpha = 0.9) +
    geom_vline(xintercept = 30, color = "red", linetype = "dashed", linewidth = 1) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    labs(title = "Site Quality Distribution", x = "Quality Score (QUAL)", y = "density")
}

# ==============================================================================
# 3. MISSING DATA PER SITE PLOT (F_MISS) - PLOT 2/5
# ==============================================================================
miss_site_file <- file.path(data_dir, "miss_site.lmiss")
if(file.exists(miss_site_file)) {
  ms_data <- read_table(miss_site_file, col_types = cols())
  
  p2 <- ggplot(ms_data, aes(x = F_MISS)) +
    geom_density(fill = fill_color, color = line_color, linewidth = line_weight, alpha = 0.9) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    labs(title = "Missing Data per Site", x = "Fraction of Missing Data (F_MISS)", y = "density")
}

# ==============================================================================
# 4. MISSING DATA PER INDIVIDUAL PLOT (F_MISS) - PLOT 3/5
# ==============================================================================
miss_ind_file <- file.path(data_dir, "miss_indv.imiss")
if(file.exists(miss_ind_file)) {
  mi_data <- read_table(miss_ind_file, col_types = cols())
  
  p3 <- ggplot(mi_data, aes(x = F_MISS)) +
    geom_density(fill = fill_color, color = line_color, linewidth = line_weight, alpha = 0.9) +
    geom_vline(xintercept = 0.15, color = "red", linetype = "dashed", linewidth = 1) + 
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) + 
    labs(title = "Missing Data per Individual", x = "Fraction of Missing Data (F_MISS)", y = "density")
}

# ==============================================================================
# 5. HETEROZYGOSITY & INBREEDING PLOT (F) - PLOT 4/5
# ==============================================================================
het_file <- file.path(data_dir, "het_indb_individu.het")
if(file.exists(het_file)) {
  het_data <- read_table(het_file, col_types = cols())
  
  p4 <- ggplot(het_data, aes(x = F)) +
    geom_density(fill = fill_color, color = line_color, linewidth = line_weight, alpha = 0.9) +
    geom_vline(xintercept = 0, color = "black", linetype = "solid") +
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    labs(title = "Inbreeding Coefficient (F)", x = "Inbreeding Coefficient (F)", y = "density")
}

# ==============================================================================
# 6. ALLELE FREQUENCY PLOT (MAF) - PLOT 5/5
# ==============================================================================
freq_file <- file.path(data_dir, "allele_freq.frq")
if(file.exists(freq_file)) {
  freq_data <- read_table(freq_file, skip = 1, col_names = FALSE, col_types = cols())
  
  maf_values <- pmin(as.numeric(freq_data$X5), as.numeric(freq_data$X6), na.rm = TRUE)
  maf_df <- data.frame(maf = maf_values)
  
  p5 <- ggplot(maf_df, aes(x = maf)) +
    geom_density(fill = fill_color, color = line_color, linewidth = line_weight, alpha = 0.9) +
    geom_vline(xintercept = 0.05, color = "red", linetype = "dashed", linewidth = 1) + 
    theme_bw() +
    theme(
      plot.title = element_text(size = 14, face = "plain", hjust = 0.5),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    ) +
    labs(title = "Minor Allele Frequency Distribution", x = "maf", y = "density")
}

# ==============================================================================
# 7. COMPILATION DU NOUVEAU RAPPORT PDF DISTINCT
# ==============================================================================
# LE NOM A BIEN ÉTÉ MODIFIÉ ICI POUR NE PAS ÉCRASER L'ANCIEN
pdf_output <- "vcf_qc_report_density.pdf"
pdf(pdf_output, width = 11, height = 8.5)

plot_list <- list(p1, p2, p3, p4, p5)
valid_plots <- plot_list[!sapply(plot_list, is.null)]

if(length(valid_plots) >= 2) {
  grid.arrange(valid_plots[[1]], valid_plots[[2]], ncol = 2, top = "VCF QC Report - Page 1 : Site Statistics")
}
if(length(valid_plots) >= 4) {
  grid.arrange(valid_plots[[3]], valid_plots[[4]], ncol = 2, top = "VCF QC Report - Page 2 : Individual Statistics")
}
if(length(valid_plots) == 5) {
  grid.arrange(valid_plots[[5]], ncol = 1, top = "VCF QC Report - Page 3 : Allele Frequency Spectrum")
}

dev.off()

print(paste("=== Success! All 5 density plots saved in:", pdf_output, "==="))
```
#### 3.5.3 Biallelic Snps filtering by QUAL and DP and statistics
```bash
bcftools view -i 'QUAL>=30' bisnps_clean_names.vcf.gz -Oz -o bisnps_clean_qual.vcf.gz
bcftools view -i 'DP>=10' bisnps_clean_qual.vcf.gz -Oz -o step2.vcf.gz
bcftools view -i 'DP<=500' step2.vcf.gz -Oz -o bisnps_clean_qual1.vcf.gz
bcftools view -i 'DP>=50' bisnps_clean_qual.vcf.gz -Oz -o step4.vcf.gz
bcftools view -i 'DP<=200' step4.vcf.gz -Oz -o bisnps_clean_qual2.vcf.gz
```
### 3.5.3 PLINK
```bash
plink --vcf all_samples_snp_filtered.vcf.gz \
      --double-id \
      --allow-extra-chr \
      --make-bed \
      --out mo_raw

plink --bfile mo_raw \
      --allow-extra-chr \
      --geno 0.5 \
      --mind 0.8 \
      --maf 0.05 \
      --indep-pairwise 50 5 0.2 \
      --make-bed \
      --out mo_work

awk '{$1=$1}1' OFS=',' pca_results.eigenvec > pca.csv

echo "FID,IID,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" > header.txt
cat header.txt pca.csv > pca_final.csv
pca <- read.csv("pca_final.csv")

head(pca)
install.packages("ggplot2")
library(ggplot2)
ggplot(pca, aes(x=PC1, y=PC2)) +
  geom_point(size=3) +
  theme_classic() +
  labs(title="PCA of Magnaporthe oryzae isolates",
       x="PC1",
       y="PC2")
# II. GIT CONFIGURATION FOR MY INTERNSHIP PROJECT
```bash
1- Creationg of repersitory "Internship_Project_CIBIG_2025"
2- Cloning of this repersitory on my Computer
3- Copying folders and files inside
4- git add .
5- git commit -m 'update somes files'
6- git push origin main
```





