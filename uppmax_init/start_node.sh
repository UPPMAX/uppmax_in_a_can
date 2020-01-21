#!/bin/bash

img_name=${1:?
    
ERROR: Image name not specified
Usage:
    ./start_node.sh <name of singularity image file>
    
Example:
    ./start_node.sh uppmax_in_a_can.sif}

singularity shell --no-home --bind mnt/sw:/sw,mnt/proj:/proj,mnt/usr/local/Modules:/usr/local/Modules,mnt/home/$a:/home/$a,mnt/crex:/crex $img_name
