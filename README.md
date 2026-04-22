# Internship_Project_CIBIG_2025

# TOPIC:  Genetic diversity study of _Magnaporthe oryzae_ population

### Lignées spécifiques de _Magnaporthe oryzae_
L’étude des structures génétiques des populations pathogènes, en lien avec des traits d'histoire de vie tels que le mode de reproduction, l'étendue des hôtes ou la résistance aux traitements, est essentielle pour comprendre l'émergence et la propagation des maladies infectieuses. Parmi les pathogènes des plantes, le champignon ascomycète _Magnaporthe oryzae_, responsable de la maladie du "blast" sur de nombreuses espèces de graminées cultivées et sauvages, constitue un modèle d'intérêt. Bien que ce pathogène soit principalement étudié pour ses effets dévastateurs sur le riz (_Oryza sativa_), il infecte également d'autres cultures céréalières, telles que le blé, l'orge et le millet, ainsi que des graminées comme le ray-grass et l'herbe de Saint-Augustin. 
Les recherches antérieures ont montré que _M. oryzae_ est subdivisé en plusieurs lignées spécifiques à leurs hôtes, avec une divergence génétique probablement liée aux changements d'hôtes. 
Cette étude vise à approfondir la compréhension de la structure génétique de plusieurs isolats de _Magnaporthe_ (voir tableau), issus de différentes espèces hôtes, pour déterminer s'ils forment des lignées hôtes-spécifiques et évaluer l'existence d'espèces cryptiques au sein de _M. oryzae_. 
En bref:

On cherche à comprendre la structure des populations de _M. oryzae_
    • Quel est le lien entre l'hôte et la structuration de la population?
    • Y a t-il des espèces cryptiques qui se détachent du reste de la population  de _M. oryzae_ ou bien _M. oryzae_ n’est constitué que d’une seule espèce, indépendamment de son hôte?
    
    
# Institutional supervisor: Prof Fidèle TIENDREBEOGO (WAVE)

# Academic supervisors: Sébastien RAVEL (CIRAD) and Christine Tranchant-Dubreuil (IRD)


# I. BIOINFORMTIC STRATEGY
# 1. Project Mind Map: 
Access link: https://mm.tt/map/3944152256?t=KJA8lJE8Ul


## 2. SEQUENCING DATA ACQUISITION
   
## 2.1. Connecting TO NCBI and EMBL-EBI
https://www.ncbi.nlm.nih.gov/
https://www.ebi.ac.uk/ena/browser/home

## 2.2. Connecting to WAVE cluster and moving to my working directory
```bash
ssh zongo@160.120.108.164
srun -c 2 -p short --nodelist=node02 --pty bash -i
cd /scratch/zongo/
```

## 2.3. Creating of my working directory and raw data sub-directory in /scratch/zongo
```bash
mkdir -p CIBIG_2025_Internship_Project/RAW_DATA
```

## 2.4. Data downloading in RAW_DATA directory from NCBI and EMBL-EBI using Isolate ID and Projects accesions
```bash
wget https:"IsolateID_R1.fastq.gz accesslink" https:"IsolateID_R2.fastq.gz accesslink"
```

## 2.5. Files renaming with R1 and R2
```bash
for f in *.fastq.gz; do
new=$(echo "$f" | sed -E 's/_1\.fastq\.gz$/_R1.fastq.gz/; s/_2\.fastq\.gz$/_R2.fastq.gz/')
    [ "$f" != "$new" ] && echo mv "$f" "$new"
done
```


# 3. DATA ANALYSES

## 3.1. Quality control
## 3.1.1. Creating a directory QC and subdirectories fastqc_results and multiqc_results
```bash
mkdir -p QC/fastqc_results QC/multiqc_results
```

### 3.1.2.Fastqc
```bash
#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --array=0-76%4
#SBATCH --output=QC/logs/fastqc_%A_%a.out
#SBATCH --error=QC/logs/fastqc_%A_%a.err

module load fastqc/0.12.1

Input_dir="RAW_DATA"
Output_dir="QC/fastqc_results"
Threads=4

mkdir -p "$Output_dir" QC/logs

# Liste des fichiers R1
samples=("$Input_dir"/*_R1.fastq.gz)
sample="${samples[$SLURM_ARRAY_TASK_ID]}"
base=$(basename "$sample" _R1.fastq.gz)

R1="$Input_dir/${base}_R1.fastq.gz"
R2="$Input_dir/${base}_R2.fastq.gz"

# Vérification de la paire
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
   echo "Missing pair: $base"
   exit 1
fi

echo "Processing sample: $base"

# Lancer FastQC directement dans Output_dir
fastqc -t "$Threads" -o "$Output_dir" "$R1" "$R2"
```

### 3.1.3. Copying fastqc_results on my computer
```bash
scp -r /scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/ /home/zongo/
```
```bash
saidou@saidou-zongo:~/Documents$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc_results .
```

### 3.1.4. MultiQC
### 3.1.5. Installation de Multiqc 1.13 à l'aide de l'installeur Miniforge
      
```bash
#!/bin/bash

# Téléchargement de Miniforge x86_64 dans mon répertoire

wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/Miniforge3-Linux-x86_64.sh

# Rendre le script exécutable
chmod +x ~/Miniforge3-Linux-x86_64.sh

# Lancement de l’installation
# Répondre 'yes' à la licence et utiliser le chemin par défaut
~/Miniforge3-Linux-x86_64.sh

# Activation de Miniforge
source ~/miniforge3/bin/activate

# Mise à jour conda
conda update -n base -c defaults conda -y

# Création d'un environnement MultiQC propre
conda create -n multiqc_env python=3.8 -y
conda activate multiqc_env

# Installation de MultiQC 1.13
conda install -c bioconda multiqc=1.13 -y
```

### 2.1.6. BATCH SCRIPT POUR MULTIQC
```bash
#!/bin/bash`
#SBATCH --job-name=multiqc
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.err
#SBATCH --nodelist=node02


set -euo pipefail

# Activation de Miniforge et de l'environnement MultiQC

source ~/miniforge3/bin/activate
conda activate multiqc_env           

# Définition des répertoires

Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_results"

mkdir -p "$Multiqc_out" QC/logs

# Lancement de  MultiQC depuis l'environnement Miniforge

multiqc "$Fastqc_dir" -o "$Multiqc_out"
```

### 3.2. TRIMMING
```bash
#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH -p normal
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.err
#SBATCH --nodelist=node02
#SBATCH --array=0-76%4       
#SBATCH -c 4

# Chargement des modules
module load bioinfo-wave
module load trimmomatic/0.39

# Définition de chemins absolus
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/RAW_DATA"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"

# Définition des listes des fichiers R1 et R2 
R1_FILES=("$INPUT_DIR"/*_R1.fastq.gz)
R2_FILES=("$INPUT_DIR"/*_R2.fastq.gz)

# Identification de l'échantillon correspondant à l'index SLURM

INDEX=$SLURM_ARRAY_TASK_ID
R1=${R1_FILES[$INDEX]}
R2=${R2_FILES[$INDEX]}

if [[ ! -f "$R1" ]] || [[ ! -f "$R2" ]]; then
    echo "Skipping index $INDEX: files missing"
    exit 1
fi

SAMPLE=$(basename "$R1" _R1.fastq.gz)

echo "Processing $SAMPLE ..."

# Trimmomatic PE 
trimmomatic PE -threads 4 -phred33 \
    "$R1" "$R2" \
    "$OUTPUT_DIR/${SAMPLE}_R1_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R1_unpaired.fastq.gz" \
    "$OUTPUT_DIR/${SAMPLE}_R2_paired.fastq.gz" "$OUTPUT_DIR/${SAMPLE}_R2_unpaired.fastq.gz" \
    SLIDINGWINDOW:4:30 \
    LEADING:3 TRAILING:3 \
    MINLEN:36

echo "Finished $SAMPLE"
```

### 3.3. MAPPING 
```bash
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
```
### 3.4. Copying Mapping_results on my computer
```bash
[zongo@node02 ~]$ scp -r /scratch/zongo/CIBIG_Internship_Project/Mapping_results/ /home/zongo/
saidou@saidou-zongo:~/Documents$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/Mapping_results .
```
# II. GIT CONFIGURATION FOR MY INTERNSHIP PROJECT
```bash
1- Creationg of repersitory "Internship_Project_CIBIG_2025"
2- Cloning of this repersitory on my Computer
3- Copying folders and files inside
4- git add .
5- git commit -m 'update somes files'
6- git push origin main
```





