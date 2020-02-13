# variables
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
export modules_shell=bash
export TERM=xterm

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

# Set UPPMAX specific variables
export CLUSTER=rackham
export MANPATH=$MANPATH:/usr/share/man:/sw/uppmax/man:/opt/thinlinc/share/man
export PATH=$PATH:/sw/uppmax/bin
export SNIC_BACKUP=/home/$USER
export SNIC_NOBACKUP=/home/$USER/glob
export SNIC_RESOURCE=$CLUSTER
export SNIC_SITE=uppmax
export SNIC_TMP=/scratch

# emulate uppmax specific aliases, since aliases can't be exported
projinfo() { /sw/uppmax/bin/projinfo $1 ; }
jobinfo() { /sw/uppmax/bin/jobinfo $1 ; }
quota() { /bin/echo Please use uquota. ; }
export -f projinfo
export -f jobinfo
export -f quota
