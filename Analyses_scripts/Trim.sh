#!/bin/bash

# Modules
module load java
module load trimmomatic/0.39

# Chemins absolus
PROJECT_DIR="/scratch/zongo/CIBIG_Internship_Project"
RAW_DIR="$PROJECT_DIR/RAW_DATA"
OUT_DIR="$PROJECT_DIR/Trimmomatic_results"
ADAPTERS="/usr/local/bioinfo/Trimmomatic-0.39/adapters/TruSeq3-PE.fa"
TRIMMOMATIC_JAR="/usr/local/bioinfo/Trimmomatic-0.39/trimmomatic-0.39.jar"

# Création du dossier résultats
mkdir -p "$OUT_DIR"

# Boucle sur tous les R1
for R1 in "$RAW_DIR"/*_R1.fastq.gz; do
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="$RAW_DIR/${SAMPLE}_R2.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "Skipping $SAMPLE: R2 missing"
        continue
    fi

    echo "Processing $SAMPLE ..."

    # Création du dossier de l'échantillon
    SAMPLE_DIR="$OUT_DIR/$SAMPLE"
    mkdir -p "$SAMPLE_DIR"

    # Trimmomatic PE
    java -jar "$TRIMMOMATIC_JAR" PE -threads 8 -phred33 \
        "$R1" "$R2" \
        "$SAMPLE_DIR/${SAMPLE}_R1_paired.fastq.gz" "$SAMPLE_DIR/${SAMPLE}_R1_unpaired.fastq.gz" \
        "$SAMPLE_DIR/${SAMPLE}_R2_paired.fastq.gz" "$SAMPLE_DIR/${SAMPLE}_R2_unpaired.fastq.gz" \
        ILLUMINACLIP:$ADAPTERS:2:30:10 \
        SLIDINGWINDOW:4:30 \
        LEADING:3 TRAILING:3 \
        MINLEN:36

    echo "Finished $SAMPLE"
done

echo "All samples processed!"
