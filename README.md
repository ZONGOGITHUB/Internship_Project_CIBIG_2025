# Internship_Project_CIBIG_2025

# TOPIC:  Genetic diversity study of Magnaporthe oryzae population

            Lignées spécifiques de Magnaporthe oryzae
L’étude des structures génétiques des populations pathogènes, en lien avec des traits d'histoire de vie tels que le mode de reproduction, l'étendue des hôtes ou la résistance aux traitements, est essentielle pour comprendre l'émergence et la propagation des maladies infectieuses. Parmi les pathogènes des plantes, le champignon ascomycète Magnaporthe oryzae, responsable de la maladie du "blast" sur de nombreuses espèces de graminées cultivées et sauvages, constitue un modèle d'intérêt. Bien que ce pathogène soit principalement étudié pour ses effets dévastateurs sur le riz (Oryza sativa), il infecte également d'autres cultures céréalières, telles que le blé, l'orge et le millet, ainsi que des graminées comme le ray-grass et l'herbe de Saint-Augustin. 
Les recherches antérieures ont montré que M. oryzae est subdivisé en plusieurs lignées spécifiques à leurs hôtes, avec une divergence génétique probablement liée aux changements d'hôtes. 
Cette étude vise à approfondir la compréhension de la structure génétique de plusieurs isolats de Magnaporthe (voir tableau), issus de différentes espèces hôtes, pour déterminer s'ils forment des lignées hôtes-spécifiques et évaluer l'existence d'espèces cryptiques au sein de M. oryzae. 
En bref:

On cherche à comprendre la structure des populations de M. oryzae.
    • Quel est le lien entre l'hôte et la structuration de la population?
    • Y a t-il des espèces cryptiques qui se détachent du reste de la population  de M. oryzae ou bien M. oryzae n’est constitué que d’une seule espèce, indépendamment de son hôte?
    
# Institutional supervisor: Prof Fidèle TIENDREBEOGO (WAVE)
# Academic supervisors: Sébastien RAVEL (CIRAD) and Christine Tranchant-Dubreuil (IRD)

# Mind Map: 
Access link: https://mm.tt/map/3944152256?t=KJA8lJE8Ul

# BIOINFORMTIC STRATEGY

 # Data acquisition
   
  # Sequencing data searching on https://www.ebi.ac.uk/ena/browser/home 

  # Connecting to WAVE cluster and moving to my working directory
   ssh zongo@160.120.108.164
   srun -c 2 -p short --nodelist=node02 --pty bash -i
   cd /scratch/zongo/

   # Creating of my working and raw data directories in /scratch/zongo directory
   mkdir -p CIBIG_2025_Internship_Project/RAW_DATA

   # fastq.gz R1 & R2 data downloading on NCBI and EMBL-EBI using Isolate ID and Projects accesions
wget https:"IsolateID_R1.fastq.gzaccesslink" https:"IsolateID_R2.fastq.gzaccesslink"

   # Quality contrôle
  #Creating a directory QC and subdirectories fastqc_results and multiqc_results
mkdir -p QC/fastqc_results QC/multiqc_results

# Run fastqc on data

Script sbatch

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


