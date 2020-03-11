# variables
export LC_ALL=C
export LMOD_CACHED_LOADS=yes
export LMOD_CMD=/usr/share/lmod/lmod/libexec/lmod
export LMOD_DEFAULT_MODULEPATH=/sw/mf/rackham/applications:/sw/mf/rackham/build-tools/:/sw/mf/rackham/compilers/:/sw/mf/rackham/data/:/sw/mf/rackham/environment/:/sw/mf/rackham/libraries/:/sw/mf/rackham/parallel/
export LMOD_DIR=/usr/share/lmod/lmod/libexec
export LMOD_PKG=/usr/share/lmod/lmod
export LMOD_SETTARG_FULL_SUPPORT=no
export LOADEDMODULES=uppmax
export MODULEPATH=/sw/mf/rackham/applications:/sw/mf/rackham/build-tools:/sw/mf/rackham/compilers:/sw/mf/rackham/data:/sw/mf/rackham/environment:/sw/mf/rackham/libraries:/sw/mf/rackham/parallel
export MODULEPATH_ROOT=/sw/mf/rackham
export MODULESHOME=/usr/share/lmod/lmod
export MODULES_CLUSTER=rackham
export MODULES_MACH=x86_64
export MODULE_INCLUDE=/sw/mf/common/includes
export MODULE_MACH=x86_64
export MODULE_VERSION=lmod
export TERM=xterm
export modules_shell=bash

# module function
module() { eval `/usr/local/Modules/$MODULE_VERSION/bin/modulecmd $modules_shell $*`; }
export -f module

# custom PS1
export PS1='\[$(tput bold)\][\t] \u@canned-uppmax \w \\$ \[$(tput sgr0)\]'

# add the scripts to the path
export PATH=$PATH:/uppmax_init/

# set the correct user name in places
export USER=$UIAC_USER
export HOME=/home/$USER
export LOGNAME=$USER
export MAIL=/var/spool/mail/$USER
export USERNAME=$USER

# Remove __LMOD__stuff. Don't look at paths that doesn't exist. Speeds up the module system from 1 minute to 1 second.
for envvar in $(env)
do
    if [[ $envvar == "__LMOD"* ]]
    then
        envvarname=$(echo $envvar | cut -d "=" -f 1)
        export $envvarname=''
    fi
done

# unload any other centra modules and load the uppmax one
module --force purge
module load uppmax

# The cluster variable is not set by the module load..
export CLUSTER=$SNIC_RESOURCE
