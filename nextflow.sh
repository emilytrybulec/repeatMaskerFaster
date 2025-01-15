#!/bin/bash
#SBATCH --job-name=nextflow
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=10G
#SBATCH --mail-user=emily.trybulec@uconn.edu

module load nextflow/23.10.1
module load singularity/vcell-3.10.0

export TMPDIR=$PWD/tmp
nextflow pull emilytrybulec/repeatMaskerFaster
chmod -R 777 /home/FCAM/etrybulec/.nextflow
nextflow run emilytrybulec/repeatMaskerFaster -params-file my_params.yaml -c my_config -profile singularity,xanadu -r main
