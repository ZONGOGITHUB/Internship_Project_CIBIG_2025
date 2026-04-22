# Internship_Project_CIBIG_2025

# TOPIC:  Genetic diversity study of _Magnaporthe oryzae_ population

### Lignées spécifiques de _Magnaporthe oryzae_
L’étude des structures génétiques des populations pathogènes, en lien avec des traits d'histoire de vie tels que le mode de reproduction, l'étendue des hôtes ou la résistance aux traitements, est essentielle pour comprendre l'émergence et la propagation des maladies infectieuses. Parmi les pathogènes des plantes, le champignon ascomycète _Magnaporthe oryzae_, responsable de la maladie du "blast" sur de nombreuses espèces de graminées cultivées et sauvages, constitue un modèle d'intérêt. Bien que ce pathogène soit principalement étudié pour ses effets dévastateurs sur le riz (_Oryza sativa_), il infecte également d'autres cultures céréalières, telles que le blé, l'orge et le millet, ainsi que des graminées comme le ray-grass et l'herbe de Saint-Augustin. 
Les recherches antérieures ont montré que _M. oryzae_ est subdivisé en plusieurs lignées spécifiques à leurs hôtes, avec une divergence génétique probablement liée aux changements d'hôtes. 
Cette étude vise à approfondir la compréhension de la structure génétique de plusieurs isolats de Magnaporthe (voir tableau), issus de différentes espèces hôtes, pour déterminer s'ils forment des lignées hôtes-spécifiques et évaluer l'existence d'espèces cryptiques au sein de _M. oryzae_. 
En bref:

On cherche à comprendre la structure des populations de _M. oryzae_.
    • Quel est le lien entre l'hôte et la structuration de la population?
    • Y a t-il des espèces cryptiques qui se détachent du reste de la population  de _M. oryzae_ ou bien M. oryzae n’est constitué que d’une seule espèce, indépendamment de son hôte?
    
    
# Institutional supervisor: Prof Fidèle TIENDREBEOGO (WAVE)

# Academic supervisors: Sébastien RAVEL (CIRAD) and Christine Tranchant-Dubreuil (IRD)

# Project Mind Map: 
Access link: https://mm.tt/map/3944152256?t=KJA8lJE8Ul



# BIOINFORMTIC STRATEGY

## Data acquisition
   
## CONNECTING TO NCBI and EMBL-EBI
https://www.ncbi.nlm.nih.gov/
https://www.ebi.ac.uk/ena/browser/home

## Connecting to WAVE cluster and moving to my working directory
ssh zongo@160.120.108.164
```srun -c 2 -p short --nodelist=node02 --pty bash -i```
```cd /scratch/zongo/```

## Creating of my working directory and raw data sub-directory in /scratch/zongo
```mkdir -p CIBIG_2025_Internship_Project/RAW_DATA```

## Data downloading in RAW_DATA directory from NCBI and EMBL-EBI using Isolate ID and Projects accesions
```wget https:"IsolateID_R1.fastq.gz accesslink" https:"IsolateID_R2.fastq.gz accesslink"```

## Files renaming with R1 and R2
```for f in *.fastq.gz; do```
```new=$(echo "$f" | sed -E 's/_1\.fastq\.gz$/_R1.fastq.gz/; s/_2\.fastq\.gz$/_R2.fastq.gz/')```
    ```[ "$f" != "$new" ] && echo mv "$f" "$new"
done```


#DATA ANALYSES

## Quality controle
## Creating a directory QC and subdirectories fastqc_results and multiqc_results
```mkdir -p QC/fastqc_results QC/multiqc_results```

### Fastqc

```#!/bin/bash```
```#SBATCH --job-name=fastqc```
```#SBATCH -p normal```
```#SBATCH -c 4```
```#SBATCH --array=0-76%4```
```#SBATCH --output=QC/logs/fastqc_%A_%a.out```
```#SBATCH --error=QC/logs/fastqc_%A_%a.err```

```module load fastqc/0.12.1```

```Input_dir="RAW_DATA"```
```Output_dir="QC/fastqc_results"```
```Threads=4```

```mkdir -p "$Output_dir" QC/logs```

```# Liste des fichiers R1```
```samples=("$Input_dir"/*_R1.fastq.gz)```
```sample="${samples[$SLURM_ARRAY_TASK_ID]}"```
```base=$(basename "$sample" _R1.fastq.gz)```

```R1="$Input_dir/${base}_R1.fastq.gz"```
```R2="$Input_dir/${base}_R2.fastq.gz"```

```# Vérification de la paire```
```if [[ ! -f "$R1" || ! -f "$R2" ]]; then```
   ``` echo "Missing pair: $base"```
   ``` exit 1```
```fi```

```echo "Processing sample: $base"```

```# Lancer FastQC directement dans Output_dir```
```fastqc -t "$Threads" -o "$Output_dir" "$R1" "$R2"```

### Copying fastqc_results on my computer
```scp -r /scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/ /home/zongo/```
```saidou@saidou-zongo:~/Documents$ rsync -ravz --progress zongo@160.120.108.164:/home/zongo/fastqc_results .```

### MultiQC

### Installation de Multiqc 1.13 à l'aide de l'installeur Miniforge
    
    
```#!/bin/bash```

```# Téléchargement de Miniforge x86_64 dans mon répertoire```

```wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/Miniforge3-Linux-x86_64.sh```

```# Rendre le script exécutable```
```chmod +x ~/Miniforge3-Linux-x86_64.sh```

```# Lancement de l’installation```
```# Répondre 'yes' à la licence et utiliser le chemin par défaut```
```~/Miniforge3-Linux-x86_64.sh```

```# Activation de Miniforge```
```source ~/miniforge3/bin/activate```

```# Mise à jour conda```
```conda update -n base -c defaults conda -y```

```# Création d'un environnement MultiQC propre```
```conda create -n multiqc_env python=3.8 -y```
```conda activate multiqc_env```

```# Installation de MultiQC 1.13```
```conda install -c bioconda multiqc=1.13 -y```

### BATCH SCRIPT SLURM POUR MULTIQC

```#!/bin/bash```
```#SBATCH --job-name=multiqc```
```#SBATCH --partition=normal```
```#SBATCH --cpus-per-task=12```
```#SBATCH --output=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.out```
```#SBATCH --error=/scratch/zongo/CIBIG_Internship_Project/QC/logs/multiqc_%j.err```
```#SBATCH --nodelist=node02```

```set -euo pipefail```

```# Activation de Miniforge et de l'environnement MultiQC```

```source ~/miniforge3/bin/activate```     
```conda activate multiqc_env```           

```# Définition des répertoires```

```Fastqc_dir="/scratch/zongo/CIBIG_Internship_Project/QC/fastqc_results/"```
```Multiqc_out="/scratch/zongo/CIBIG_Internship_Project/QC/multiqc_results"```

```mkdir -p "$Multiqc_out" QC/logs```

```# Lancement de  MultiQC depuis l'environnement Miniforge```

```multiqc "$Fastqc_dir" -o "$Multiqc_out"```



