# Internship_Project_CIBIG_2025


# SUPERVISORS

# Institutional supervisor: Prof Fidèle TIENDREBEOGO (WAVE)

# Academic supervisors: Sébastien RAVEL (CIRAD) and Christine Tranchant-Dubreuil (IRD)



# I. TOPIC PRESENTATION AND RESEARCH QUESTIONS:  Genetic structure study of _Magnaporthe oryzae_ population

### Lignées spécifiques de _Magnaporthe oryzae_
L’étude des structures génétiques des populations pathogènes, en lien avec des traits d'histoire de vie tels que le mode de reproduction, l'étendue des hôtes ou la résistance aux traitements, est essentielle pour comprendre l'émergence et la propagation des maladies infectieuses. Parmi les pathogènes des plantes, le champignon ascomycète _Magnaporthe oryzae_, responsable de la maladie du "blast" sur de nombreuses espèces de graminées cultivées et sauvages, constitue un modèle d'intérêt. Bien que ce pathogène soit principalement étudié pour ses effets dévastateurs sur le riz (_Oryza sativa_), il infecte également d'autres cultures céréalières, telles que le blé, l'orge et le millet, ainsi que des graminées comme le ray-grass et l'herbe de Saint-Augustin. 
Les recherches antérieures ont montré que _M. oryzae_ est subdivisé en plusieurs lignées spécifiques à leurs hôtes, avec une divergence génétique probablement liée aux changements d'hôtes. 
Cette étude vise à approfondir la compréhension de la structure génétique de plusieurs isolats de _Magnaporthe_ (voir tableau), issus de différentes espèces hôtes, pour déterminer s'ils forment des lignées hôtes-spécifiques et évaluer l'existence d'espèces cryptiques au sein de _M. oryzae_. 
En bref:

On cherche à comprendre la structure des populations de _M. oryzae_
1) Quel est le lien entre l'hôte et la structuration de la population?
2) Y a t-il des espèces cryptiques qui se détachent du reste de la population  de _M. oryzae_ ou bien _M. oryzae_ n’est constitué que d’une seule espèce, indépendamment de son hôte?


# II. PROJECT MIND MAP
It includes the general context, study objective and research questions, bibliography, data bases, data collection and molecular analysis methodology, the bioinformatic strategy that we will be used to address research questions, the reporting of our analysis
results and the reproducibility of our bioinformatic workflow
Access link: https://mm.tt/map/3944152256?t=KJA8lJE8Ul


# III. BIOINFORMATIC STRATEGY

## 1. SEQUENCING DATA ACQUISITION

## 1.1. Connecting to NCBI and EMBL-EBI ENA
https://www.ncbi.nlm.nih.gov/
https://www.ebi.ac.uk/ena/browser/home

## 1.2. Connecting to WAVE cluster and moving to my working directory
```bash
ssh login@160.120.108.164
srun -c 2 -p short --nodelist=node02 --pty bash -i
cd /scratch/username/
```

## 1.3. Creating of my working directory and raw data sub-directory in /scratch/zongo
```bash
mkdir -p CIBIG_2025_Internship_Project/Data
```

## 1.4. Sequences downloading in RAW_DATA directory from NCBI and EMBL-EBI ENA using Isolate identifiers and Projects accession numbers
```bash
wget https:"IsolateID_R1.fastq.gz accesslink" https:"IsolateID_R2.fastq.gz accesslink"
```

## 1.5. Sequences renaming with R1 and R2
```bash
for f in *.fastq.gz; do
    new=$(echo "$f" | sed -E 's/_1\.fastq\.gz$/_R1.fastq.gz/; s/_2\.fastq\.gz$/_R2.fastq.gz/')

    if [ "$f" != "$new" ]; then
        mv -i "$f" "$new"
        echo "$f -> $new"
    fi
done
```


# 2. DATA ANALYSIS

## 2.1. SEQUENCES QUALITY CONTROL

## 2.1.1. Creating a directory QC and subdirectories fastqc and multiqc
```bash
mkdir -p Results/QC/fastqc Results/QC/multiqc
```

### 2.1.2.Fastqc
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

### 2.1.3. Copying fastqc results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc .
```

### 2.1.4. MultiQC

### 2.1.5. Multiqc 1.13 installing using Miniforge
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

### 2.1.6. Multiqc script
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

### 2.1.7. Copying multiqc results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/multiqc/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/multiqc .
```


## 2.2. READS TRIMMING/CLEANING
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

### 2.2.1. Fastqc on trimmed data
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

### 2.2.2. Copying fastqc_trimmed results on my gitclone
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/Results/QC/fastqc_trimmed/ /home/zongo/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc_trimmed .
```

### 2.2.3. Multiqc on trimmed data
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

### 2.2.4. Copying fastqc_trimmed results on my gitclone
```bash
scp -r /scratch/user/CIBIG_Internship_Project/Results/QC/multiqc_trimmed/ /home/user/
```
```bash
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/multiqc_trimmed .
```


## 2.3. MAPPING 
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
# Construction of corresponding R2 file path
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

    echo “✅ Done for $sample”
done
```

## 2.4. Copying Mapping_results on my computer
```bash
[zongo@node02 ~]$ scp -r /scratch/zongo/CIBIG_Internship_Project/Mapping/ /home/zongo/
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/Mapping .
```

## 2.5. SNPs CALLING AND FILTERING
### 2.5.1 Reference genome indexing
```bash
module load bioinfo_wave
module load samtools/1.23.1
samtools faidx /scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna
```

### 2.5.2 Raw snps calling 
```bash
#!/bin/bash

#SBATCH --job-name=raw_snpcalling
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/logs/rawsnp_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/logs/rawsnp_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# ===================== MODULES LOADING  =====================
module load bioinfo-wave
module load bcftools/1.18

# ===================== PATHS =====================
BAM_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping_sorted"
REF="/scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Results/SNP_calling"

mkdir -p "$OUTPUT_DIR"

# ===================== OUTPUT FILES =====================
RAW_VCF="$OUTPUT_DIR/raw_vcf.vcf.gz"
SNP_VCF="$OUTPUT_DIR/rawsnps.vcf.gz"
SNP_STATS_FILE="$OUTPUT_DIR/rawsnps_stats.txt"


# ===================== RAW VCF GENERATING =====================
bcftools mpileup --threads 12 -Ou -f "$REF" "$BAM_DIR"/*_sorted.bam | \
bcftools call -mv -Oz -o "$RAW_VCF"

bcftools index "$RAW_VCF"

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

### 2.5.3. Biallelic snps calling and statistics 
```bash
bcftools view --threads 8 -m2 -M2 -v snps rawsnps.vcf.gz -Oz -o bisnps.vcf.gz
bcftools stats bisnps.vcf.gz > bisnps_stats.txt
```

### 2.5.4. Renaming of bisnps.vcf.gz files to obtain names with only isolates ID
```bash
#!/bin/bash

set -e

# --- Modules loading ---
echo "=== Configuration des modules ==="
module purge
module load bioinfo-wave
module load bcftools/1.18

# --- Configuration of files  ---
OLD_VCF="bisnps.vcf.gz"
CLEAN_VCF="bisnps_clean_names.vcf.gz"

# 1. VCF files old names extraction
bcftools query -l "$OLD_VCF" > old_names.txt

# 2. New names creating
sed 's|.*/||; s|_sorted.bam||' old_names.txt > new_names.txt

# 3. New names table creating
paste old_names.txt new_names.txt > rename_table.txt

# 4. New names application
bcftools reheader --samples rename_table.txt -o "$CLEAN_VCF" "$RAW_VCF"

# 5. Deleting text files
rm old_names.txt new_names.txt rename_table.txt

echo "=== Renaming succed! ==="
```

### 2.5.5. Biallelic snps quality control
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

### 2.5.6. Biallelic snps parameters plotting in R
```bash
# 1. AUTOMATIC PACKAGE INSTALLATION AND LIBRARY LOADING
required_packages <- c("tidyverse", "gridExtra")

# Packages installation
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://r-project.org")

# Libraries loading
library(tidyverse)
library(gridExtra)

# Folder of parameters 
data_dir <- "/home/saidou/bisnps_check"

print("=== Starting VCF QC Density Visualization ===")

# Initialisation of  variables to  NULL
p1 <- p2 <- p3 <- p4 <- p5 <- NULL

# Configuration of colors
fill_color  <- "#bcdffc"
line_color  <- "black"
line_weight <- 1.2

# 2. SITE QUALITY PLOT (QUAL) - PLOT 1/5
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

# 3. MISSING DATA PER SITE PLOT (F_MISS) - PLOT 2/5
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

# 4. MISSING DATA PER INDIVIDUAL PLOT (F_MISS) - PLOT 3/5
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

# 5. HETEROZYGOSITY & INBREEDING PLOT (F) - PLOT 4/5
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

# 6. ALLELE FREQUENCY PLOT (MAF) - PLOT 5/5

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

# 7. COMPILATION OF THE REPORT IN PDF 
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

### 2.5.7. Biallelic Snps filtering and statistics
```bash
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
```


## 2.6.  ASSESSMENT OF THE GENETIC STRUCTURE OF _Magnaporthe oryzae_ Population

### Import VCF → PLINK
```bash
plink --vcf filtered_bisnps.vcf.gz –allow-extra-chr --double-id --set-missing-var-ids @:# --make-bed --out filtered_bisnps_plink
```
### LD pruning
```bash
plink --bfile filtered_bisnps_plink \
  --allow-extra-chr \
  --indep-pairwise 50 5 0.4 \
  --out filtered_bisnps_ld
```
### Pruned SNPs extraction
```bash
plink --bfile filtered_bisnps_plink\
  --allow-extra-chr \
  --extract filtered_bisnps_ld.prune.in \
  --make-bed \
  --out filtered_bisnps_final
```
### .raw conversion for ADGENET in R
```bash
plink --bfile filtered_bisnps_final \
  --recode A \
  --allow-extra-chr \
  --out bisnps_final
```

### 2.6.1. Principal Component Analysis (PCA)
```bash
# 1. PACKAGES
library(adegenet)
library(ggplot2)
library(dplyr)

# 2. IMPORT PLINK RAW FILE
raw <- read.table(
  "bisnps_final.raw",
  header = TRUE,
  stringsAsFactors = FALSE
)

# 3. EXTRACT SNP MATRIX

# PLINK columns:
# 1 FID
# 2 IID
# 3 PAT
# 4 MAT
# 5 SEX
# 6 PHENOTYPE
# SNPs start at column 7
geno <- raw[,7:ncol(raw)]

# 4. CONVERT TO MATRIX
geno <- as.matrix(geno)

# 5. HANDLE MISSING DATA
geno[is.na(geno)] <- mean(geno, na.rm = TRUE)

# 6. PCA
pca <- dudi.pca(
  geno,
  cent = TRUE,
  scale = FALSE,
  scannf = FALSE,
  nf = 3
)

# 7. EXPLAINED VARIANCE
var_exp <- pca$eig / sum(pca$eig) * 100

# 8. IMPORT METADATA
meta <- read.table(
  "metadata.txt",
  header = TRUE,
  sep = ",",
  stringsAsFactors = FALSE
)

# 9. CLEAN METADATA
meta$IID  <- trimws(meta$IID)
meta$Host <- trimws(meta$Host)

# 10. ALIGN ISOLATES
meta <- meta[
  match(raw$IID, meta$IID),
]

# 11. BUILD PCA DATAFRAME
df <- data.frame(
  PC1 = pca$li[,1],
  PC2 = pca$li[,2],
  isolat = raw$IID,
  host = meta$Host
)

# 12. CHECK DATASET
cat("Number of isolates:\n")
print(length(unique(df$isolat)))

cat("Number of hosts:\n")
print(length(unique(df$host)))

cat("Host distribution:\n")
print(table(df$host))

# 13. FILTER FOR ELLIPSES
df_ell <- df %>%
  group_by(host) %>%
  filter(n() >= 5) %>%
  ungroup()

# 14. PCA PLOT
p1 <- ggplot(
  df,
  aes(PC1, PC2, color = host)
) +

  geom_point(
    size = 3,
    alpha = 0.9
  ) +

  stat_ellipse(
    data = df_ell,
    aes(PC1, PC2, color = host),
    type = "t",
    level = 0.95,
    linewidth = 1
  ) +

  theme_classic() +

  labs(
    title = "PCA of Magnaporthe oryzae populations",
    
    x = paste0(
      "PC1 (",
      round(var_exp[1],1),
      "%)"
    ),

    y = paste0(
      "PC2 (",
      round(var_exp[2],1),
      "%)"
    ),

    color = "Host"
  ) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),

    legend.position = "right"
  )


# 15. DISPLAY PCA
p1

# 16. EXPORT FIGURES
ggsave(
  "PCA_final.png",
  p1,
  width = 8,
  height = 6,
  dpi = 600
)
```

### 2.6.2. Discriminant Analysis of Principal Components (DAPC)
```bash
# 1. PACKAGES
library(adegenet)
library(ggplot2)
library(dplyr)

# 2. IMPORT PLINK RAW FILE
raw <- read.table(
  "mooryzae_final.raw",
  header = TRUE,
  stringsAsFactors = FALSE
)

# 3. EXTRACT SNP MATRIX
# PLINK columns:
# 1 FID
# 2 IID
# 3 PAT
# 4 MAT
# 5 SEX
# 6 PHENOTYPE
# SNPs start at column 7

geno <- raw[,7:ncol(raw)]

# 4. CONVERT TO MATRIX
geno <- as.matrix(geno)

# 5. HANDLE MISSING DATA
geno[is.na(geno)] <- mean(geno, na.rm = TRUE)

# 6. CLEAN SNP NAMES
colnames(geno) <- make.names(
  colnames(geno),
  unique = TRUE
)

# 7. IMPORT METADATA
meta <- read.table(
  "metadata.txt",
  header = TRUE,
  sep = ",",
  stringsAsFactors = FALSE
)

# 8. CLEAN METADATA
meta$IID  <- trimws(meta$IID)
meta$Host <- trimws(meta$Host)

# 9. ALIGN ISOLATES
meta <- meta[
  match(raw$IID, meta$IID),
]

# 10. DEFINE GROUPS
grp <- as.factor(meta$Host)
# 11. CHECK DATASET
cat("Number of isolates:\n")
print(length(unique(raw$IID)))

cat("Number of hosts:\n")
print(length(unique(grp)))

cat("Host distribution:\n")
print(table(grp))

# 12. DAPC
dapc_res <- dapc(
  geno,
  grp,
  n.pca = 20,
  n.da = 4
)

# 13. EXTRACT DAPC COORDINATES
df <- data.frame(
  LD1 = dapc_res$ind.coord[,1],
  LD2 = dapc_res$ind.coord[,2],
  host = grp,
  isolat = raw$IID
)

# 14. FILTER FOR ELLIPSES
df_ell <- df %>%
  group_by(host) %>%
  filter(n() >= 5) %>%
  ungroup()

# 15. DAPC PLOT
p_dapc <- ggplot(
  df,
  aes(LD1, LD2, color = host)
) +

  geom_point(
    size = 3,
    alpha = 0.9
  ) +

  stat_ellipse(
    data = df_ell,
    aes(LD1, LD2, color = host),
    type = "t",
    level = 0.95,
    linewidth = 1
  ) +

  theme_classic() +

  labs(
    title = "DAPC of Magnaporthe oryzae populations",

    x = "LD1",
    y = "LD2",

    color = "Host"
  ) +

  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5
    ),

    legend.position = "right"
  )

# 16. DISPLAY DAPC
p_dapc

# 17. EXPORT FIGURES
ggsave(
  "DAPC_final_ellipse.png",
  p_dapc,
  width = 8,
  height = 6,
  dpi = 600
)
```

### 2.6.3. Phylogeny: IQ_TREE
#### Conversion PHYLIP
```bash
vcf2phylip.py -i filtered_bisnps_final.vcf -o iqtree.phy
```
#### IQ-TREE Maximum likelihood
```bash
iqtree2 \
  -s iqtree.phy \
  -m MFP \
  -B 1000 \
  --bnni \
  -nt AUTO
```

```bash
# Libraries
library(ape)
library(ggtree)
library(ggplot2)
library(dplyr)

# 1. READ IQ-TREE
tree <- read.tree("iqtree_ld.min4.phy.treefile")

# Clean duplicated labels
tree$tip.label <- sub("_.*$", "", tree$tip.label)

# Clean spaces
tree$tip.label <- trimws(tree$tip.label)

# Convert bootstrap labels safely
tree$node.label <- suppressWarnings(
  as.numeric(tree$node.label)
)

# 2. READ METADATA
meta <- read.csv(
  "metadata.txt",
  header = TRUE,
  stringsAsFactors = FALSE
)

# Rename columns
colnames(meta) <- c("IID", "Host")

# Clean metadata
meta$IID  <- trimws(meta$IID)
meta$Host <- trimws(meta$Host)

# 3. CHECK CONSISTENCY
cat("Matching isolates:\n")
print(length(intersect(tree$tip.label, meta$IID)))

cat("Tree not in metadata:\n")
print(setdiff(tree$tip.label, meta$IID))

cat("Metadata not in tree:\n")
print(setdiff(meta$IID, tree$tip.label))

# 4. KEEP COMMON ISOLATES
common <- intersect(tree$tip.label, meta$IID)

tree <- keep.tip(tree, common)

meta <- meta %>%
  filter(IID %in% common)

# 5. FORMAT FOR GGTREE
meta2 <- data.frame(
  label = meta$IID,
  host  = meta$Host
)

# 6. BUILD TREE
p <- ggtree(
  tree,
  branch.length = "none"
) %<+% meta2 +

  # Tree branches
  geom_tree(
    linewidth = 0.7,
    linetype = "solid"
  ) +

  # Tip points
  geom_tippoint(
    aes(color = host),
    size = 2.5
  ) +

  # Tip labels
  geom_tiplab(
    size = 2,
    align = TRUE,
    offset = 0.01
  ) +

  # Host colors
  scale_color_manual(
    values = rainbow(length(unique(meta2$host))),
    name = "Host"
  ) +

  # Theme
  theme_tree2() +

  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 9)
  )

# 7. ADD BOOTSTRAP SUPPORT
p <- p +
  geom_text2(
    aes(
      subset = !isTip &
               !is.na(label) &
               label >= 70,
      label = label
    ),
    hjust = -0.3,
    size = 2
  )

# 8. DISPLAY TREE
p

# 9. EXPORT FIGURES
ggsave(
  "IQTREE_FINAL_PUBLICATION.png",
  plot = p,
  width = 10,
  height = 10,
  dpi = 600
)
```
