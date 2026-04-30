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
    [ "$f" != "$new" ] && mv -i "$f" "$new"
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

# Slurm configuration
#SBATCH --job-name=fastqc
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --array=0-76%4
#SBATCH --output=QC/logs/fastqc_%A_%a.out
#SBATCH --error=QC/logs/fastqc_%A_%a.err

# Module loading
module load bioinfo-wave
module load fastqc/0.12.1

# Directories
Input_dir="RAW_DATA"
Output_dir="QC/fastqc_results"
Threads=4

mkdir -p "$Output_dir" QC/logs

# R1 files list
samples=("$Input_dir"/*_R1.fastq.gz)
sample="${samples[$SLURM_ARRAY_TASK_ID]}"
base=$(basename "$sample" _R1.fastq.gz)

R1="$Input_dir/${base}_R1.fastq.gz"
R2="$Input_dir/${base}_R2.fastq.gz"

# R2 files checking
if [[ ! -f "$R1" || ! -f "$R2" ]]; then
   echo "Missing pair: $base"
   exit 1
fi

echo "Processing sample: $base"

# Fastqc running
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

### 2.1.6. Multiqc script
```bash
#!/bin/bash`

# Slurm configuration
#SBATCH --job-name=multiqc
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.err
#SBATCH --nodelist=node02


set -euo pipefail

# Miniforge and MultiQC environment activation

source ~/miniforge3/bin/activate
conda activate multiqc_env           

# Directories

Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_results"

mkdir -p "$Multiqc_out" QC/logs

# Multiqc running

multiqc "$Fastqc_dir" -o "$Multiqc_out"
```

### 3.2. TRIMMING
```bash
#!/bin/bash

# Slurm configuration
#SBATCH --job-name=trimmomatic
#SBATCH -p normal
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/trimmomatic_%j.err
#SBATCH --nodelist=node02
#SBATCH --array=0-76%4       
#SBATCH -c 4

# Modules loading
module load bioinfo-wave
module load trimmomatic/0.39

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/RAW_DATA"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"

#  R1 et R2 files listes
R1_FILES=("$INPUT_DIR"/*_R1.fastq.gz)
R2_FILES=("$INPUT_DIR"/*_R2.fastq.gz)

# Samples index SLURM

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

### 3.3. Fastqc on trimmed data
```bash

#!/bin/bash

# Slurm configuration
#SBATCH --job-name=fastqc_trim
#SBATCH --exclude=node01,node03,node05,node06
#SBATCH -p normal
#SBATCH -c 4
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/fastqc_trim.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/fastqc_trim.err

# Modules loading
module load bioinfo-wave
module load fastqc/0.12.1

#Directories

INPUT="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"
OUTPUT="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_trim_results"

mkdir -p "$OUTPUT"

echo "FastQC en cours..."


find "$INPUT" -name "*_R1_paired.fastq.gz" | xargs -n 1 -P 2 bash -c '
R1="$1"
R2="${R1/_R1_/_R2_}"
[[ -f "$R2" ]] || exit
fastqc -threads 4 -o "'"$OUTPUT"'" "$R1" "$R2"
' _
```

### 3.4. Multiqc on trimmed data
```bash
#!/bin/bash

# Slurm configuration
#SBATCH --job-name=multiqc_trim
#SBATCH --partition=normal
#SBATCH --nodelist=node02
#SBATCH -c 2
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_trim_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_trim_%j.err

set -euo pipefail

# Miniforge and multiqc activation
source ~/miniforge3/bin/activate
conda activate multiqc_env

# Directories
Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_trim_results/"
Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_trim_results"

mkdir -p "$Multiqc_out"
# Multiqc running
multiqc "$Fastqc_dir" -o "$Multiqc_out"
```

### 3.5. MAPPING 
```bash
#!/bin/bash

# Slurm configuration
#SBATCH --job-name=mapping
#SBATCH --partition=normal
#SBATCH --cpus-per-task=12
#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.out
#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/mapping_%j.err
#SBATCH --nodelist=node02

set -euo pipefail

# Directories
INPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Trimmomatic_results"
OUTPUT_DIR="/scratch/zongo/CIBIG_Internship_Project/Mapping_results"
REF_GENOME="/scratch/zongo/CIBIG_Internship_Project/GCF_000002495.2_MG8_genomic.fna"

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





