#!/bin/bash

# Dossier contenant les fichiers .stats
FOLDER="/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Analyses_Results/MAPPING/Mapping_stats_results"  # Mets ton chemin ici
OUTPUT="mapping_summary.csv"

# En-tête du fichier CSV
echo "File,Total Reads,Mapped Reads,Mapped (%),Unmapped Reads,Unmapped (%)" > "$OUTPUT"

# Parcours de tous les fichiers .stats
for FILE in "$FOLDER"/*.stats; do
    # Extraction des valeurs avec awk et regex
    TOTAL=$(awk -F: '/Total reads/ {gsub(/ /,"",$2); print $2}' "$FILE")
    MAPPED=$(awk -F: '/Mapped reads/ {gsub(/[^0-9]/,"",$2); print $2}' "$FILE")
    MAPPED_PERCENT=$(awk -F'[()%]' '/Mapped reads/ {gsub(/ /,"",$2); print $2}' "$FILE")

    # Calcul des reads non mappés et pourcentage
    UNMAPPED=$((TOTAL - MAPPED))
    UNMAPPED_PERCENT=$(awk -v t="$TOTAL" -v u="$UNMAPPED" 'BEGIN {printf "%.2f", (u/t)*100}')

    # Écriture dans le CSV
    echo "$(basename "$FILE"),$TOTAL,$MAPPED,$MAPPED_PERCENT,$UNMAPPED,$UNMAPPED_PERCENT" >> "$OUTPUT"
done

echo "Analyse terminée ! Résultats dans $OUTPUT"
