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

