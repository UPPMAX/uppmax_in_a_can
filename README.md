# UPPMAX in a can 
This Singularity container will let you run a near-identical UPPMAX environment on your own computer. You will have access to all of the installed software at UPPMAX, all your files and reference data on UPPMAX, but it will be your own computer that does the calculations. You can even use it to analyse data that you only have on your own computer, but using the software and reference data on UPPMAX.

# Typical use cases
* You have sensitive data that is not allowed to leave your computers, but you want to use the programs and references at UPPMAX to do the analysis.
* You have your own server but want to avoid installing all the software yourself.
* The queues at UPPMAX are too long or you have run out of core hours but you want the analysis done yesterday.
* You have your data and compute hours at another SNIC centre, but want to use the software installed at UPPMAX.

# What you get
* Access to your home folder and all project folders.
* Access to all the installed programs at UPPMAX.
* Access to all reference data at UPPMAX.

# What you don't get
* UPPMAX high-performace computers. You will be limited by the computer you are running the container on.
* No slurm access. Everything runs on your computer.

# Important notes
* Since all data you read/write to the UPPMAX file system will have to travel over the internet, disk intensive programs will be much slower, and transfer rate is limited to your internet connection. Try working on your local harddrive as much as possible.

# Issues
* Some of the tools at uppmax, like projinfo and uquota are using your user's group membership to determin what information to show. Since your local user won't have the same groups as you have on uppmax they misbehave and will not show you the same information as when you run the program on uppmax.
* If your user has not connected to uppmax before it will need to accept the login nodes fingerprint before connecting (a security feature). Sshfs will just hang if this happens, so you will have to connect normally to uppmax and manually accept the fingerprint. To make things more complicated there are 3 different login nodes, each with its own fingerprint, and you are randomly assigned to one. There is a possibility to turn this off in the sshfs mount command by adding `-o StrictHostKeyChecking=no`, but it might not be a good idea to disable it due to security. Easiest way around it is just to run `ssh user@rackham.uppmax.uu.se` a couple of times until you have seen all 3 fingerprints.

# Prerequisites
This tool has been developed on Ubuntu 18.04 with Singularity v.3.5. You should only need 2 things for this to work,

* [Singularity (only tested with v3.5)](https://sylabs.io/guides/3.5/user-guide/quick_start.html)
* [SSHFS](https://github.com/libfuse/sshfs)  
(Make sure that the option `user_allow_other` is uncommented in `/etc/fuse.conf`)

For installation instructions for these, see respective projects homepage.

# Installation

### Using a pre-built image

```bash
singularity pull shub://UPPMAX/uppmax_in_a_can:latest
```

### Building your own image from github. 
Clone the github repo and build the image:

```bash
git clone https://github.com/UPPMAX/uppmax_in_a_can.git
cd uppmax_in_a_can
singularity build uppmax_in_a_can_latest.sif Singularity
```

The build takes 10-20 minutes on a modern laptop with gigabit Ethernet. 


# Usage

## First time usage
Once the build is done, run the initialization script in the container,

```bash
./uppmax_in_a_can_latest.sif uppmax_init

# to see more options, run
./uppmax_in_a_can_latest.sif
```

## Subsequent usage
Start the virtual node:

```bash
./uiac_node.sh -i uppmax_in_a_can_latest.sif

# to see more options, run
./uiac_node.sh -h
```

You will now be on the command-line inside the container and you can run commands as if you were logged in on UPPMAX. You will see all project folders in `/proj`, all software in `/sw`, your UPPMAX home folder in `/home/<UPPMAX_username>`

```bash
# ex
module load bioinf-tools samtools
samtools view file.bam
```

To close down and return to your own computers command-line, just type `exit`.

# Advanced usage

You can also specify any additional singularity options to the `uiac_node.sh` script. If you want to make your computers file system visible inside the container so that you can analyse files residing on your computer, just add a bind argument:

```bash
# Entire hard drive 
./uiac_node.sh -e "--bind /:/hostfs" -i uppmax_in_a_can_latest.sif

# Only a specific directory
./uiac_node.sh -e "--bind /home/user/data:/hostfs" -i uppmax_in_a_can_latest.sif
```

This command will make your computers file system available under `/hostfs` (or wherever you would like it).


# Developer notes

To get the list of installed software on UPPMAX, run this command on UPPMAX:
`yum list installed | cut -f 1 -d " " | cut -f 1 -d "." | sort | tr '\n' ' '  > yum_installed_`date +%F.txt`

This list will contain **all** installed packages, even core packages and nvidia packages that are not available in the default repos. It will just give a couple of warning messages when you send the list to `yum install`, but it will not break the installation process.

To get the the list of environment variables in `env/99-uppmaxvars.sh`, type `env | egrep -i 'module|lmod' | sort` when logged in on UPPMAX and pick out everything that has to do with the module system.

The PS1 is made to be different from the default shell the user has to make it obvious they are inside the container.

