#!/bin/bash

#set -e
#set -x

img_name="image_name.sif"

# get the uppax username
echo "UPPMAX username:"
read a

# check if anything needs unmounting
read -r mount_sw mount_proj mount_crex mount_home mount_module <<< $(echo 0 0 0 0 0)
[[ -d mnt/sw/mf ]] || mount_sw=1
[[ -L mnt/proj/staff ]] || mount_proj=1
[[ -d mnt/crex/proj ]] || mount_crex=1
[[ -f mnt/home/$a/.bashrc ]] || mount_home=1
[[ -d mnt/usr/local/Modules/lmod ]] || mount_module=1

# get the uppmax password
if [[ $((mount_sw+mount_proj+mount_crex+mount_home+mount_module)) > 0 ]] ;
then
    echo "UPPMAX password:"
    read -s l
fi

# init structure
mkdir -p mnt/home/$a
mkdir -p mnt/proj
mkdir -p mnt/sw
mkdir -p mnt/crex
mkdir -p mnt/usr/local/Modules

# mount stuff if needed
[[ $mount_sw == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/sw/ mnt/sw <<< $l
[[ $mount_proj == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/proj/ mnt/proj <<< $l
[[ $mount_crex == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/crex/ mnt/crex <<< $l
[[ $mount_home == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/home/$a mnt/home/$a <<< $l
[[ $mount_module == 0 ]] || sshfs -o allow_other,password_stdin $a@rackham.uppmax.uu.se:/usr/local/Modules mnt/usr/local/Modules <<< $l

# no keep
unset l

# for the cow
read -r mount_sw mount_proj mount_crex mount_home mount_module <<< $(echo 0 0 0 0 0)
[[ -d mnt/sw/mf ]] || mount_sw=1
[[ -L mnt/proj/staff ]] || mount_proj=1
[[ -d mnt/crex/proj ]] || mount_crex=1
[[ -f mnt/home/$a/.bashrc ]] || mount_home=1
[[ -d mnt/usr/local/Modules/lmod ]] || mount_module=1

if [[ $((mount_sw+mount_proj+mount_crex+mount_home+mount_module)) == 0 ]] ;
then
    echo """ ________________________________________
/ All good, partner. Let's get this show \ 
\ on the road.                           / 
 ----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\ 
                ||----w |
                ||     ||
"""
fi

singularity shell --no-home --bind mnt/sw:/sw,mnt/proj:/proj,mnt/usr/local/Modules:/usr/local/Modules,mnt/home/$a:/home/$a,mnt/crex:/crex $img_name
