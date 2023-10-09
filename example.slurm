#!/bin/bash
#SBATCH -J example
#SBATCH -o %x_output.txt
#SBATCH -e %x_errors.txt
#SBATCH -t 24:00:00
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -p allgroups
#SBATCH --gres=gpu:rtx
#SBATCH --mem-per-cpu=48G
#SBATCH --mail-user example@dei.unipd.it
#SBATCH --mail-type ALL
cd $WORKING_DIR

srun singularity exec --bind /nfsd/iaslab4/Users/rossi/example_code_repo:/mnt --nv /nfsd/iaslab4/Users/rossi/example_code_repo/example.sif python3 /mnt/example_train.py
