# variables
export __LMOD_REF_COUNT_MODULEPATH=/sw/mf/rackham/applications:/sw/mf/rackham/build-tools:/sw/mf/rackham/compilers:/sw/mf/rackham/data:/sw/mf/rackham/environment:/sw/mf/rackham/libraries:/sw/mf/rackham/parallel:
export LMOD_DEFAULT_MODULEPATH=/sw/mf/rackham/applications:/sw/mf/rackham/build-tools/:/sw/mf/rackham/compilers/:/sw/mf/rackham/data/:/sw/mf/rackham/environment/:/sw/mf/rackham/libraries/:/sw/mf/rackham/parallel/
export MODULEPATH_ROOT=/sw/mf/rackham
export LMOD_PKG=/usr/share/lmod/lmod
export MODULE_INCLUDE=/sw/mf/common/includes
export __LMOD_REF_COUNT_LOADEDMODULES=uppmax:2
export MODULE_MACH=x86_64
export __LMOD_REF_COUNT__LMFILES_=/sw/mf/rackham/environment/uppmax:1
export MODULE_VERSION=lmod
export MODULES_MACH=x86_64
export MODULEPATH=/sw/mf/rackham/applications:/sw/mf/rackham/build-tools:/sw/mf/rackham/compilers:/sw/mf/rackham/data:/sw/mf/rackham/environment:/sw/mf/rackham/libraries:/sw/mf/rackham/parallel
export LOADEDMODULES=uppmax
export LMOD_CMD=/usr/share/lmod/lmod/libexec/lmod
export __LMOD_REF_COUNT_PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sw/uppmax/bin:2
export MODULES_CLUSTER=rackham
export MODULESHOME=/usr/share/lmod/lmod
export LMOD_SETTARG_FULL_SUPPORT=no
export __LMOD_REF_COUNT_MANPATH=/usr/share/man:/sw/uppmax/man:/opt/thinlinc/share/man:2
export LMOD_DIR=/usr/share/lmod/lmod/libexec
export modules_shell=bash

# QoL
alias l='ls -l --color=auto --group-directories-first'
alias ll='ls -la --color=auto --group-directories-first'

# module function
module() { eval `/usr/local/Modules/$MODULE_VERSION/bin/modulecmd $modules_shell $*`; }
export -f module

# custom PS1
export PS1="\[$(tput bold)\][\t] \u@canned-uppmax \w \\$ \[$(tput sgr0)\]"

# add the scripts to the path
export PATH=$PATH:/uppmax_init/
