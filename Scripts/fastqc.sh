
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
