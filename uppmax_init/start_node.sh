#!/bin/bash

# check that at least one argument is given to the script
img_name=${1:?
    
ERROR: Image name not specified
Usage:
    ./start_node.sh [singularity options] <name of singularity image file>
    
Example:
    ./start_node.sh uppmax_in_a_can.sif
    
    # or any additional valid singularity arguments.
    # the example below will mount your computers file system
    # inside the container under /hostfs
    ./start_node.sh --bind /:/hostfs uppmax_in_a_can.sif}

singularity shell --no-home --bind mnt/sw:/sw,mnt/proj:/proj,mnt/usr/local/Modules:/usr/local/Modules,mnt/home/$a:/home/$a,mnt/crex:/crex $@
