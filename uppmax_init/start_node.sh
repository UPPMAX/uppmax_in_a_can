#!/bin/bash
set -e

#  ___                                   _               _    
# |_ _|_ __ ___   __ _  __ _  ___    ___| |__   ___  ___| | __
#  | || '_ ` _ \ / _` |/ _` |/ _ \  / __| '_ \ / _ \/ __| |/ /
#  | || | | | | | (_| | (_| |  __/ | (__| | | |  __/ (__|   < 
# |___|_| |_| |_|\__,_|\__, |\___|  \___|_| |_|\___|\___|_|\_\
#                      |___/                                  
# Image check

# check that at least one argument is given to the script
img_name=${1:?
    
ERROR: Image name not specified
Usage:
    ./start_node.sh [-m] [singularity options] <name of singularity image file>
    
Example:
    ./start_node.sh uppmax_in_a_can_latest.sif
    
    # or any additional valid singularity arguments.
    # the example below will mount your computers file system
    # inside the container under /hostfs
    ./start_node.sh --bind /:/hostfs uppmax_in_a_can_latest.sif

    # if only -m is given as argument, the script will only
    # mount the sshfs shares and then exit without starting
    # the container.

}





print_usage() {
  usage="""
  $(basename $0)
  -------------------------------------
  A wraper to start the UPPMAX container.

  Usage:
  bash $(basename $0) -i <input dir> -o <output dir> [-b <barcode override> -c <channel names override> -q -j <imgs per job> -s <subset to this number of imgsets>]

  Options:
  -i    Input directory containing images (will get all images recursivly).
  -e	Extra Singularity options to be passed, e.g. additional --bind
  -m	Mount the sshfs shares only, don't start the container. 
  -s	Start the container only, don't mount the sshfs shars. 

"""
  printf "$usage"

}


# check arguments
while getopts 'i:ems:' flag; do
  case "${flag}" in
    i) image="${OPTARG}" ;;
    e) extra_options="${OPTARG}" ;;
    m) mount_only=1 ;;
    s) start_only=1 ;;
    *) print_usage
       exit 1 ;;
  esac
done


#  __  __                   _   
# |  \/  | ___  _   _ _ __ | |_ 
# | |\/| |/ _ \| | | | '_ \| __|
# | |  | | (_) | |_| | | | | |_ 
# |_|  |_|\___/ \__,_|_| |_|\__|
#                               
# Mount

# check if sshfs in is the path
[[ $(command -v sshfs) ]] || { printf 'There is no sshfs in your PATH. Please run 

singularity exec uppmax_in_a_can_latest.sif sshfs_extract ; PATH=$PATH:$(pwd) ; ./start_node.sh uppmax_in_a_can_latest.sif

to get a precompiled sshfs executable that could work on your system. If it does not, please install sshfs on your own (https://github.com/libfuse/sshfs).
' ; exit 1; }

# get the uppmax username
printf "UPPMAX username: "
read a

# init structure
mkdir -p mnt/crex
mkdir -p mnt/etc
mkdir -p mnt/home/
mkdir -p mnt/proj
mkdir -p mnt/sw
mkdir -p mnt/usr/local/Modules

# Create a sshfs mount function
function sshfs_mount () {
    share_name=${1:? share_name/ missing}

    # Check if sub directory is mounted
    if [[ -d mnt/$share_name/${sub_mount[$share_name]} ]] || [[ -L mnt/$share_name/${sub_mount[$share_name]} ]]
    then
        printf "Mounting %-20s DONE\n" $share_name 
    else

        # Get password unless we already have it.
        if [[ -z "$l" ]]
        then
            printf "UPPMAX password: "
            read -s l
            printf "\n"
        fi

        # Mount the directory
        printf "Mounting %-20s \r" $share_name
        sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/"$share_name/" mnt/"$share_name/" <<< $l
        if [[ $? != 0 ]]
        then
            printf "Mounting /$share_name/ %-20s FAILED!\n"
            exit 1
        fi
        printf "Mounting %-20s DONE\n" $share_name
    fi
}

# Mount necessary directories
mounts=(crex etc home proj sw usr/local/Modules)
declare -A sub_mount=( \
    ["crex"]="proj" \
    ["etc"]="yum" \
    ["home"]="$a" \
    ["proj"]="staff" \
    ["sw"]="mf" \
    ["usr/local/Modules"]="lmod")

for mount in ${mounts[@]}
do 
    sshfs_mount $mount
done

#  ____  _    _             _             _
# / ___|| | _(_)_ __    ___| |_ __ _ _ __| |_
# \___ \| |/ / | '_ \  / __| __/ _` | '__| __|
#  ___) |   <| | |_) | \__ \ || (_| | |  | |_
# |____/|_|\_\_| .__/  |___/\__\__,_|_|   \__|
#              |_|
# Skip start

# check if the user only wants to mount the sshfs shares
if [[ "$1" == "-m" ]]
then
    printf "All mounts are up, exiting.\n"
    exit
fi

#  ____  _             _                     _      
# / ___|| |_ __ _ _ __| |_   _ __   ___   __| | ___ 
# \___ \| __/ _` | '__| __| | '_ \ / _ \ / _` |/ _ \
#  ___) | || (_| | |  | |_  | | | | (_) | (_| |  __/
# |____/ \__\__,_|_|   \__| |_| |_|\___/ \__,_|\___|
#                                                   
# Start node

singularity shell --contain --home /home/$USER:/hosthome --bind mnt/sw:/sw,mnt/proj:/proj,mnt/usr/local/Modules:/usr/local/Modules,mnt/home/:/home/,mnt/crex:/crex,mnt/etc:/etc $@

