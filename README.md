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

```

### 3.4. Copying Mapping_results on my computer
```bash
[zongo@node02 ~]$ scp -r /scratch/zongo/CIBIG_Internship_Project/Mapping/ /home/zongo/
saidou@saidou-zongo:/media/saidou/ZONGO/GITCLONE_Project_CIBIG_2025/Results$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/Mapping .
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





