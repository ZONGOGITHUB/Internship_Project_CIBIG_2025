#!/bin/bash
#SBATCH --job-name=mapping
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# --------- Répertoires ---------
TRIM_DIR="/scratch/zongo/CIBIG_Internship_Project/Trim_results"
RESULTS_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping_results"
REF_GENOME="/scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna"

mkdir -p "$RESULTS_DIR"

# --------- Modules ---------
module load bioinfo-wave
module load bwamem2/2.3
module load samtools/1.23.1

# --------- Indexation du génome ---------
if [[ ! -f "${REF_GENOME}.bwt.2bit.64" ]]; then
    echo "Index BWA inexistant, création en cours..."
    bwa-mem2 index "$REF_GENOME"
    echo "Index créé."
else
    echo "Index BWA trouvé, utilisation de l'existant."
fi

# --------- Boucle sur les échantillons ---------
for fq1 in "$TRIM_DIR"/*_R1_paired.fastq.gz; do

    # Vérifie qu'il y a au moins un fichier
    if [[ ! -e "$fq1" ]]; then
        echo "Aucun fichier *_R1_paired.fastq.gz trouvé dans $TRIM_DIR"
        exit 1
    fi

    fq2="${fq1/_R1_paired.fastq.gz/_R2_paired.fastq.gz}"
    sample=$(basename "$fq1" _R1_paired.fastq.gz)

    # --------- Vérification des fichiers FASTQ ---------
    if [[ ! -f "$fq2" ]]; then
        echo "Fichier R2 manquant pour $sample → skip"
        continue
    fi

    echo "======================================"
    echo "Traitement du sample : $sample"
    echo "R1 : $fq1"
    echo "R2 : $fq2"
    echo "======================================"

    # --------- Chemins de sortie ---------
    bam_unsorted="$RESULTS_DIR/${sample}_unsorted.bam"
    bam_filtered="$RESULTS_DIR/${sample}_filtered.bam"
    bam_sorted="$RESULTS_DIR/${sample}_sorted.bam"
    stats_out="$RESULTS_DIR/${sample}_stats.txt"

    # --------- Mapping ---------
    echo "Mapping avec BWA-MEM2..."
    bwa-mem2 mem -t "$SLURM_CPUS_PER_TASK" "$REF_GENOME" "$fq1" "$fq2" | \
        samtools view -@ "$SLURM_CPUS_PER_TASK" -Sb - > "$bam_unsorted"

    # --------- Filtrage ---------
    echo "Filtrage MAPQ >= 30..."
    samtools view -@ "$SLURM_CPUS_PER_TASK" -b -q 30 "$bam_unsorted" > "$bam_filtered"
    rm -f "$bam_unsorted"

    # --------- Statistiques ---------
    echo "Statistiques..."
    samtools flagstat -@ "$SLURM_CPUS_PER_TASK" "$bam_filtered" > "$stats_out"

    # --------- Tri ---------
    echo "Tri du BAM..."
    samtools sort -@ "$SLURM_CPUS_PER_TASK" -o "$bam_sorted" "$bam_filtered"
    rm -f "$bam_filtered"

    # --------- Indexation ---------
    echo "Indexation..."
    samtools index "$bam_sorted"

    echo "✅ Terminé pour $sample"
    echo

done

echo "Tous les échantillons ont été traités avec succès."
