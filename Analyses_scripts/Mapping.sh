#!/bin/bash
#SBATCH --job-name=mapping
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Définition des répertoires
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping_results"
REF_GENOME="/scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna"

mkdir -p "$OUTPUT_DIR"

# Chargement des modules
module load bioinfo-wave
module load bwamem2/2.3
module load samtools/1.23.1

# Indexation du génome de référence
if [[ ! -f "${REF_GENOME}.bwt.2bit.64" ]]; then
    echo "Index BWA inexistant, création en cours..."
    bwa-mem2 index "$REF_GENOME"
    echo "Index créé."
else
    echo "Index BWA trouvé, utilisation de l'existant."
fi

# Boucle sur les séquences
for R1 in "$INPUT_DIR"/*_R1_paired.fastq.gz; do

    # Déduction du nom du sample à partir du fichier R1
    sample=$(basename "$R1" _R1_paired.fastq.gz)
    # Construction du chemin du fichier R2 correspondant
    R2="$INPUT_DIR/${sample}_R2_paired.fastq.gz"

    # Définition des chemins de sortie
    BAM_FILE="$OUTPUT_DIR/${sample}.bam"
    STATS_FILE="$OUTPUT_DIR/${sample}_stats.txt"
    FILTERED_FILE="$OUTPUT_DIR/${sample}_filtered.bam"
    SORTED_FILE="$OUTPUT_DIR/${sample}_sorted.bam"

    # Mapping
    bwa-mem2 mem -t 12 "$REF_GENOME" "$R1" "$R2" | samtools view -@ 12 -Sb - > "$BAM_FILE"

    # Statistiques sur les BAM
    samtools flagstat "$BAM_FILE" > "$STATS_FILE"

    # Filtrage des BAM
    samtools view -b -q 30 "$BAM_FILE" > "$FILTERED_FILE"
    rm -f "$BAM_FILE"

    # Tri des filtered.bam avec MAPQ >= 30
    samtools sort -o "$SORTED_FILE" "$FILTERED_FILE"
    rm -f "$FILTERED_FILE"

    # Indexation des sorted.bam
    samtools index "$SORTED_FILE"

    echo "✅ Terminé pour $sample"
done
