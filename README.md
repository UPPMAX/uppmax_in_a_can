# UPPMAX in a can
This Singularity container will let you run a near-identical UPPMAX environment on your own computer. You will have access to all of the installed software at UPPMAX, all your files and reference data on UPPMAX, but it will be your own computer that does the calculations. You can even use it to analyse data that you only have on your own computer, but using the software and reference data on UPPMAX.

# What you get
* Access to your home folder and all project folders.
* Access to all the installed programs at UPPMAX.
* Access to all reference data at UPPMAX.

# What you don't get
* UPPMAX high-performace computers. You will be limited by the computer you are running the container on.
* No slurm access. Everything runs on your computer.

# Important notes
* The first time you run `module` it will have to go through all the module files at UPPMAX, which takes quite a bit longer when you do it over a sshfs connection. It could take a minute or two. After that initial command, the module list will be cached and subsequent request should be much faster.
* Since all data you read/write to the UPPMAX file system will have to travel over the internet, disk intensive programs will be much slower, and transfer rate is limited to your internet connection.

# Prerequisites
This tool has been developed on Ubuntu 18.04 with Singularity v.3.5. You should only need 2 things for this to work,

* [Singularity (only tested with v3.5)](https://sylabs.io/guides/3.5/user-guide/quick_start.html)
* [SSHFS](https://github.com/libfuse/sshfs)

For installation instructions for these, see respective projects homepage.

# Installation

#### Using a pre-built image

```bash
singularity pull shub://UPPMAX/uppmax_in_a_can
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

`singularity exec uppmax_in_a_can_latest.sif uppmax_init`

## Subsequent usage
Start the virtual node:
`./start_node.sh uppmax_in_a_can_latest.sif`

You will now be on the command-line inside the container and you can run commands as if you were logged in on UPPMAX. You will see all project folders in `/proj`, all software in `/sw`, your UPPMAX home folder in `/home/<UPPMAX_username>`

```bash
# ex
module load bioinf-tools samtools
samtools view file.bam
```

To close down and return to your own computers command-line, just type `exit`.

# Advanced usage

You can also specify any additional singularity options to the `start_node.sh` script. If you want to make your computers file system visible inside the container so that you can analyse files residing on your computer, just add a bind argument:

```bash
# Entire hard drive 
./start_node.sh --bind /:/hostfs uppmax_in_a_can_latest.sif

# Only a specific directory
./start_node.sh --bind /home/user/data:/hostfs uppmax_in_a_can_latest.sif
```

This command will make your computers file system available under `/hostfs` (or wherever you would like it).

If you want to run specific commands rather than be dropped on an interactive command-line, you can use the `exec` argument to singularity.


```bash
singularity exec --containall --bind mnt/crex:/crex,mnt/etc:/etc,mnt/home/:/home/,mnt/proj:/proj,mnt/sw:/sw,mnt/usr/local/Modules:/usr/local/Modules uppmax_in_a_can_latest.sif <custom commands here>
```


# Developer notes

To get the list of installed software on UPPMAX, run this command on UPPMAX:
`yum list installed | cut -f 1 -d " " | cut -f 1 -d "." | sort > yum_installed.txt`

This list will contain **all** installed packages, even core packages and nvidia packages that are not available in the default repos. It will just give a couple of warning messages when you send the list to `yum install`, but it will not break the installation process.

To get the the list of environment variables in `env/99-uppmaxvars.sh`, type `env | egrep -i 'module|lmod' | sort` when logged in on UPPMAX and pick out everything that has to do with the module system.

The PS1 is made to be different from the default shell the user has to make it obvious they are inside the container.

