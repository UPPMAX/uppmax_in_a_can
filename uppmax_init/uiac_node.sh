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


default_image_name="uppmax_in_a_can_latest.sif"

print_usage() {
  usage="""
  $(basename $0)
  -------------------------------------
  A wraper to start the UPPMAX container.

  Usage:
  bash $(basename $0) [-i <image file> -msud -e \"<extra options>\" -p <path to mount point dir> -n <uppmax username> -k <path to ssh key> -c \"<command to execute in the container>\"]

  Options:
  -i    Path to the Singularity image file (default: $default_image_name=)
  -e	Extra Singularity options to be passed, e.g. additional --bind
  -m	Mount the sshfs shares only, don't start the container.
  -p    Path to where mount points for sshfs will be created (default: ./)
  -s	Start the container only, don't mount the sshfs shars.
  -u	Unmount sshfs shares only, don't start the container.
  -d	Disable host fingerprint check (Not recommended).
  -n    Give the uppmax username as an option instead of a interactive question.
  -k    Path to the ssh key you want to use to login to uppmax with sshfs.
  -c    Command to run in the container (will start container with exec instead of shell).
  -q    Run quietly, only printing error messages.

"""
  printf "$usage" >&2

}

# check arguments
while getopts ':i:e:msuhp:dn:k:c:q' flag; do
  case "${flag}" in
    i) image="${OPTARG}" ;;
    e) extra_options="${OPTARG}" ;;
    m) mount_only=1 ;;
    p) mountpoint_dir="${OPTARG}";;
    s) start_only=1 ;;
    u) unmount_only=1 ;;
    d) disable_fingerprint=",StrictHostKeyChecking=no" ;;
    n) username="${OPTARG}" ;;
    k) key_file=",IdentityFile=${OPTARG}" ;;
    c) cmd="${OPTARG}" ;;
    q) quiet=1 ;;
    *) print_usage
       exit 1 ;;
  esac
done

### Sanity check

# make sure only one flag is given
if (( (mount_only+start_only+unmount_only) > 1 )) 
then
    printf "ERROR: -m, -s and -u are mutually exclusive, only specify one of them.\n" >&2
    exit 1
fi

### make sure image is specified if it is set to start
# if image will be started
if [[ -z "$mount_only" ]] && [[ -z "$unmount_only" ]]
then
    # if image not specified
    if [[ -z "$image" ]]
    then
        # check if there is a file with the default name and use that
        if [[ -f "$default_image_name" ]] || [[ -L "$default_image_name" ]]
        then
            [[ -n $quiet ]] || printf "INFO: Image file not specified (-i), using ./$default_image_name since it exists.\n\n"
            image="$default_image_name"
        else
            printf "ERROR: Image file not specified (-i)\n\n" >&2
            print_usage
            exit 1
        fi
    fi
fi

# set default values
if [[ -z "$mountpoint_dir" ]]
then
    mountpoint_dir=.
fi

# if no ssh key file is specified, the user has to supply a password
if [[ -z "$key_file" ]]
then
    key_file=",password_stdin"
fi

# check if sshfs in is the path
[[ $(command -v sshfs) ]] || { printf "There is no sshfs in your PATH. Please run 

./$default_image_name sshfs_extract ; PATH=\$PATH:\$(pwd) ; ./uiac_node.sh -i $default_image_name

to get a precompiled sshfs executable that could work on your system. If it does not, please install sshfs on your own (https://github.com/libfuse/sshfs)." >&2 ; exit 1; }

#  __  __                   _   
# |  \/  | ___  _   _ _ __ | |_ 
# | |\/| |/ _ \| | | | '_ \| __|
# | |  | | (_) | |_| | | | | |_ 
# |_|  |_|\___/ \__,_|_| |_|\__|
#                               
# Mount

# not needed if unmounting only
if [[ $unmount_only != 1 ]] && [[ -z "$username"  ]]
then
    # get the uppmax username
    printf "UPPMAX username: "
    read username
fi

# Define mounts
mounts=(crex etc home proj sw usr/local/Modules)
declare -A sub_mount=( \
    ["crex"]="proj" \
    ["etc"]="yum" \
    ["home"]="$username" \
    ["proj"]="staff" \
    ["sw"]="mf" \
    ["usr/local/Modules"]="lmod")

# don't mount if not needed
if (( start_only+unmount_only == 0 ))
then


    # Create a sshfs mount function
    function sshfs_mount () {
        share_name=${1:? share_name/ missing}

        # Check if sub directory is mounted
        if [[ -d "$mountpoint_dir"/mnt/$share_name/${sub_mount[$share_name]} ]] || [[ -L "$mountpoint_dir"/mnt/$share_name/${sub_mount[$share_name]} ]]
        then
            [[ -n $quiet ]] || printf "Mounting %-20s SKIPPING, ALREADY DONE\n" $share_name 
        else

            # Get password unless we already have it.
            if [[ -z "$password" ]] && [[ $key_file == ",password_stdin" ]]
            then
                printf "UPPMAX password: "
                read -s password
                printf "\n"
            fi

            # Mount the directory (StrictHostKeyChecking=no to skip sshkey?)
            [[ -n $quiet ]] || printf "Mounting %-20s \r" $share_name
            sshfs \
                -o allow_other$disable_fingerprint$key_file \
                $username@rackham.uppmax.uu.se:"/$share_name/" \
                "$mountpoint_dir"/mnt/"$share_name" <<< $password

            if [[ $? != 0 ]]
            then
                printf "Mounting /$share_name/ %-20s FAILED!\n" >&2
                exit 1
            fi
            [[ -n $quiet ]] || printf "Mounting %-20s DONE\n" $share_name
        fi
    }

    for mount in ${mounts[@]}
    do
        # create mount point if needed
        mkdir -p "$mountpoint_dir"/mnt/$mount

        # mount the share
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
        [[ -n $quiet ]] || printf "Unmounting %-20s \r" $mount

        # first kill all processes still using the mount, then unmount it
        fuser -k "$mountpoint_dir"/mnt/$mount
        fusermount -u "$mountpoint_dir"/mnt/$mount
        if [[ $? != 0 ]]
        then
            printf "Unmounting /$mount/ %-20s FAILED!\n" >&2
        else
            [[ -n $quiet ]] || printf "Unmounting %-20s DONE\n" $mount
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
    [[ -n $quiet ]] || printf "Skipping starting container as requested.\n"
    exit 0
fi




#  ____  _             _                     _      
# / ___|| |_ __ _ _ __| |_   _ __   ___   __| | ___ 
# \___ \| __/ _` | '__| __| | '_ \ / _ \ / _` |/ _ \
#  ___) | || (_| | |  | |_  | | | | (_) | (_| |  __/
# |____/ \__\__,_|_|   \__| |_| |_|\___/ \__,_|\___|
#                                                   
# Start node

# feel free to try to make this into a single line.. darn auto-adding quotes..
# if the user want to run a command in the container instead of opening an interactive shell
if [[ -n "$cmd" ]]
then
    mode="exec"
    SINGULARITYENV_UIAC_USER="$username" singularity $mode --no-home --home /home/"$username" --contain --bind "$mountpoint_dir"/mnt/sw:/sw,"$mountpoint_dir"/mnt/proj:/proj,"$mountpoint_dir"/mnt/usr/local/Modules:/usr/local/Modules,"$mountpoint_dir"/mnt/home/:/home/,"$mountpoint_dir"/mnt/crex:/crex $extra_options "$image" bash -c "$cmd"


else
    mode="shell"
    SINGULARITYENV_UIAC_USER="$username" singularity $mode --no-home --home /home/"$username" --contain --bind "$mountpoint_dir"/mnt/sw:/sw,"$mountpoint_dir"/mnt/proj:/proj,"$mountpoint_dir"/mnt/usr/local/Modules:/usr/local/Modules,"$mountpoint_dir"/mnt/home/:/home/,"$mountpoint_dir"/mnt/crex:/crex $extra_options "$image"
fi


