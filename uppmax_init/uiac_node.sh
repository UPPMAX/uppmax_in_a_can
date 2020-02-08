#!/bin/bash

#set -e
#set -x
#trap read debug

#  ___                                   _               _    
# |_ _|_ __ ___   __ _  __ _  ___    ___| |__   ___  ___| | __
#  | || '_ ` _ \ / _` |/ _` |/ _ \  / __| '_ \ / _ \/ __| |/ /
#  | || | | | | | (_| | (_| |  __/ | (__| | | |  __/ (__|   < 
# |___|_| |_| |_|\__,_|\__, |\___|  \___|_| |_|\___|\___|_|\_\
#                      |___/                                  
# Image check

print_usage() {
  usage="""
  $(basename $0)
  -------------------------------------
  A wraper to start the UPPMAX container.

  Usage:
  bash $(basename $0) [-i <input dir>] [-msu] [-e \"<extra options>\"]

  Options:
  -i    Input directory constituting the Singularity image
  -e	Extra Singularity options to be passed, e.g. additional --bind
  -m	Mount the sshfs shares only, don't start the container. 
  -s	Start the container only, don't mount the sshfs shars. 
  -u	Unmount sshfs shares only, don't start the container.

"""
  printf "$usage"

}

# check arguments
while getopts ':i:e:msuh' flag; do
  case "${flag}" in
    i) image="${OPTARG}" ;;
    e) extra_options="${OPTARG}" ;;
    m) mount_only=1 ;;
    s) start_only=1 ;;
    u) unmount_only=1 ;;
    *) print_usage
       exit 1 ;;
  esac
done

### Sanity check

# make sure only one flag is given
if (( (mount_only+start_only+unmount_only) > 1 )) 
then
    printf "-m, -s and -u are mutually exclusive, only specify one of them.\n"
    exit 1
fi

# make sure image is specified
if [[ -z "$image" ]]
then
    printf "ERROR: Image directory not specified (-i)\n\n"
    print_usage
    exit 1
fi




#  __  __                   _   
# |  \/  | ___  _   _ _ __ | |_ 
# | |\/| |/ _ \| | | | '_ \| __|
# | |  | | (_) | |_| | | | | |_ 
# |_|  |_|\___/ \__,_|_| |_|\__|
#                               
# Mount

# not needed if unmounting only
if [[ $unmount_only != 1 ]]
then
    # get the uppmax username
    printf "UPPMAX username: "
    read a
fi

# Define mounts
mounts=(crex etc home proj sw usr/local/Modules)
declare -A sub_mount=( \
    ["crex"]="proj" \
    ["etc"]="yum" \
    ["home"]="$a" \
    ["proj"]="staff" \
    ["sw"]="mf" \
    ["usr/local/Modules"]="lmod")

# don't mount if not needed
if (( start_only+unmount_only == 0 ))
then

    # check if sshfs in is the path
    [[ $(command -v sshfs) ]] || { printf 'There is no sshfs in your PATH. Please run 

    singularity exec uppmax_in_a_can_latest.sif sshfs_extract ; PATH=$PATH:$(pwd) ; ./start_node.sh uppmax_in_a_can_latest.sif

    to get a precompiled sshfs executable that could work on your system. If it does not, please install sshfs on your own (https://github.com/libfuse/sshfs).
    ' ; exit 1; }

    # Create a sshfs mount function
    function sshfs_mount () {
        share_name=${1:? share_name/ missing}

        # Check if sub directory is mounted
        if [[ -d $image/mnt/$share_name/${sub_mount[$share_name]} ]] || [[ -L $image/mnt/$share_name/${sub_mount[$share_name]} ]]
        then
            printf "Mounting %-20s SKIPPING, ALREADY DONE\n" $share_name 
        else

            # Get password unless we already have it.
            if [[ -z "$l" ]]
            then
                printf "UPPMAX password: "
                read -s l
                printf "\n"
            fi

            # Mount the directory (StrictHostKeyChecking=no to skip sshkey?)
            printf "Mounting %-20s \r" $share_name
            sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/"$share_name/" $image/mnt/"$share_name/" <<< $l
            if [[ $? != 0 ]]
            then
                printf "Mounting /$share_name/ %-20s FAILED!\n"
                exit 1
            fi
            printf "Mounting %-20s DONE\n" $share_name
        fi
    }

    for mount in ${mounts[@]}
    do 
        sshfs_mount $mount
    done
fi




#  _   _                                   _
# | | | |_ __  _ __ ___   ___  _   _ _ __ | |_
# | | | | '_ \| '_ ` _ \ / _ \| | | | '_ \| __|
# | |_| | | | | | | | | | (_) | |_| | | | | |_
#  \___/|_| |_|_| |_| |_|\___/ \__,_|_| |_|\__|
#
# Umount

if (( unmount_only==1 ))
then


    for mount in ${mounts[@]}
    do
        printf "Unmounting %-20s \r" $mount 
        fusermount -u $image/mnt/$mount
        if [[ $? != 0 ]]
        then
            printf "Mounting /$mount/ %-20s FAILED!\n"
        else
            printf "Mounting %-20s DONE\n" $mount
        fi
    done
fi




#  ____  _    _             _             _
# / ___|| | _(_)_ __    ___| |_ __ _ _ __| |_
# \___ \| |/ / | '_ \  / __| __/ _` | '__| __|
#  ___) |   <| | |_) | \__ \ || (_| | |  | |_
# |____/|_|\_\_| .__/  |___/\__\__,_|_|   \__|
#              |_|
# Skip start

# check if the user only wants to mount the sshfs shares
if (( mount_only+unmount_only > 0 ))
then
    printf "Skipping starting container as requested.\n"
    exit 0
fi




#  ____  _             _                     _      
# / ___|| |_ __ _ _ __| |_   _ __   ___   __| | ___ 
# \___ \| __/ _` | '__| __| | '_ \ / _ \ / _` |/ _ \
#  ___) | || (_| | |  | |_  | | | | (_) | (_| |  __/
# |____/ \__\__,_|_|   \__| |_| |_|\___/ \__,_|\___|
#                                                   
# Start node

# update the uppmax username in the image directory
printf "$a" > $image/uppmax_init/username.txt

singularity shell --no-home --contain --bind $image/mnt/sw:/sw,$image/mnt/proj:/proj,$image/mnt/usr/local/Modules:/usr/local/Modules,$image/mnt/home/:/home/,$image/mnt/crex:/crex $extra_options $image

