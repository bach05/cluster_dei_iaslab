# Instruction to use DEI Cluster @ iaslab

The following instructions are meant to iaslab mambers. Please, refere to the complete [online guide](https://clusterdeiguide.readthedocs.io/en/latest/) for all the deatils. 

The cluster works using SLURM scheduler. You are supposed to submit a job which will be managed by the scheduler and execute as soon as possible. 

# Preparing the code

We advise to test the code locally before submitting to the cluster. It is not straighforward to debug code on the cluster. 

Please prepare the github repository. 

# Preparing the Singularity container

Install singularity and prepare the container. Firslt, create a folder to compile the image container: 

```shell
mkdir image
cd image
```

For deep learning with Pytorch, you can rely on this example file `ubuntu_cuda.def`. It builds an Ubuntu 20.04 container with cuda libraries. Add `pip install ...` to install the packages you need. 

```
BootStrap: docker
From: nvidia/cuda:11.5.1-cudnn8-devel-ubuntu20.04

%post
    apt update -y
    apt install -y python3.8
    apt update -y
    apt install -y pip
    apt update -y
    pip install numpy==1.21.6
    pip install torch==1.13.0
    pip install torchvision==0.14.0

%environment
   export LC_ALL=C

%runscript

```

Build the image

```
 singularity build ubuntu_cuda.sif ubuntu_cuda.def
```

There are also other modalities, please refer to this [guide](https://guiesbibtic.upf.edu/recerca/hpc/building-singularity-containers). 


# Prepare the cluster environment in the cluster

Access to your DEI account

```shell
ssh youraccount@login.dei.unipd.it

```
In your home you have only 5GB, if you need more space, you should access our NAS. 
```shell
cd /nfsd/iaslab4/Users/your_surname
```
If the folder with your surname does not exist, please create it. 

Clone your repository with the code. Copy also the `.sif` image container in the repository folder (rembeer to update `.gitignore` file). 

## Cpoy file into your workspae folder

If you are inside DEI network, you can access the NAS through the file manager using samba. Please, refer to the following image:

![Alt text](./images/nas_access.png)

If you are outside DEI network, use `scp` (`-r` will recursevely copy all the subfolders):

```shell
scp -r /path_to_resource ursername@login.dei.unipd.it:/nfsd/iaslab4/Users/your_surname/

```

# Manage a job

Prepare a `.slurm` file in `/nfsd/iaslab4/Users/your_surname` to submit a job. All the instructions and details can be found [here](https://clusterdeiguide.readthedocs.io/en/latest/UsingSLURM.html). Please, read it before submitting a job. 

You can use the following file as a reference example: 

```slurm
#!/bin/bash
#SBATCH -J [job_identifier_name]
#SBATCH -o %x_output.txt
#SBATCH -e %x_errors.txt
#SBATCH -t [expected execution time]
#SBATCH -n 1
#SBATCH -c [cpu core to be used]
#SBATCH -p allgroups
#SBATCH --gres=gpu:[required gpu]
#SBATCH --mem-per-cpu=[required RAM amount]
#SBATCH --mail-user [your email to receive notifications about job status]
#SBATCH --mail-type ALL
cd $WORKING_DIR

srun singularity exec --bind /nfsd/iaslab4/Users/[your_folder]/[your_repo]:/mnt --nv /nfsd/iaslab4/Users/[your_folder]/[your_repo]/[your_image].sif python3 /mnt/[your_script.py] 

```

Please substitute [] with your specs. 

Note the all the path by default refers to your `/home` directory. We use `--bind /nfsd/iaslab4/Users/[your_folder]/[your_repo]:/mnt` to simplfy the mapping. `/mnt` now is pseudonym for `/nfsd/iaslab4/Users/[your_folder]/[your_repo]`. All the path in your code must start with `/mnt`, otherwise the they will refer to `/home`. 

## Submit the job

To submit your job: 
```shell
sbatch your_file.slurm

```
To check the status you can use `%x_output.txt` (standard output) and `%x_errors.txt` (standard error). Basically they collect the info that normally are printed into the console. 

To get info about your job status, running time, etc..., you can also run: 
```shell
squeue -o "%.18i %.9P %.35j %.8u %.2t %.10M %.6D %R"  | grep [username]
```
You will get information in this format
```shell
job_id | group | job_name | job_status | running_time | numn_task | running_node
```

Some status codes inlcude: 
- `COMPLETED CD`: 	The job has completed successfully.
- `COMPLETING 	CG`: 	The job is finishing but some processes are still active.
- `FAILED 	F`: 	The job terminated with a non-zero exit code and failed to execute.
- `PENDING 	PD`: 	The job is waiting for resource allocation. It will eventually run.
- `PREEMPTED 	PR`: 	The job was terminated because of preemption by another job.
- `RUNNING 	R`: 	The job currently is allocated to a node and is running.
- `SUSPENDED 	S`: 	A running job has been stopped with its cores released to other jobs.
- `STOPPED 	ST 	A`: running job has been stopped with its cores retained.


To cancel a job:
```shell
scancel [job_id]
```




