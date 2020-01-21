# UPPMAX in a can
Using Singularity to create a near-identical UPPMAX environment for development. It runs on your own computer but gives you access to the files at UPPMAX.

# What you get
* Same OS and almost all packages installed at UPPMAX.
* Access to the whole module system.
* Access to your home folder and all project folders.
* Access to all reference data.

# What you don't get
* No slurm access. Everything runs on your computer.


# Prerequisites
You should only need 2 things for this to work,

* [Singularity (only tested with v3.5)](https://sylabs.io/guides/3.5/user-guide/quick_start.html)
* [SSHFS](https://github.com/libfuse/sshfs)

For installation instructions for these, see respective projects homepage.

# Installation
Clone the github repo and build the image:


```bash
git clone https://github.com/UPPMAX/uppmax_in_a_can.git
cd uppmax_in_a_can
singularity build uppmax_in_a_can.sif uppmax_in_a_can.def
```

The build takes 10-20 minutes on a modern laptop with gigabit ethernet. Once the build is done, run the initialization script in the container to setup the folder structure needed to create sshfs mount points:

`singularity exec uppmax_in_a_can.sif uppmax_init`

# Usage

Before starting the container you have to run the mount script to set up the sshfs mount points:
`./mount_sshfs.sh`

Then you can start the virtual node:
`./start_node.sh uppmax_in_a_can.sif`

You will now be on the command-line inside the container and you can run commands as if you were logged in on uppmax. You will see all project folders in /proj, all software in /sw, your uppmax home folder in /home/$USER

```bash
# ex
module load bioinf-tools ; module load samtools
samtools view file.bam
```

To close down and return to your own computers command-line, just type `exit`.

# Advanced usage

If you want to run specific commands rather than be dropped on an interactive command-line, you can use the exec argument to singularity.


```bash
singularity exec --no-home --bind mnt/sw:/sw,mnt/proj:/proj,mnt/usr/local/Modules:/usr/local/Modules,mnt/home/UPPMAX_USERNAME:/home/UPPMAX_USERNAME uppmax_in_a_can.sif <custom commands here>
```


# Background info

To get the list of installed software on uppmax:
`yum list installed | cut -f 1 -d " " | cut -f 1 -d "." | sort > yum_installed.txt`

This list will contain **all** installed packages, even core packages and nvidia packages that are not available in the default repos. It will just give a couple of warning messages when you send the list to `yum install`, but it will not break the installation process.

To get the the list of environment variables in `env/99-uppmaxvars.sh`, type `env | egrep -i 'module|lmod' | sort` when logged in on uppmax and pick out everything that has to do with the module system.

The PS1 is made to be different from the default shell the user has to make it obvious they are inside the container.

