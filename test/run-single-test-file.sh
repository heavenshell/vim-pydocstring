#!/bin/sh

###############################################################################
#                         Execute a single test file                          #
###############################################################################

if [ $# -eq 0 ]; then
  echo "Please supply an input *.vader file"
  exit
fi

: "${VIM_EXE:=vim}"

if  hash nvim 2>/dev/null ; then
  VIM_EXE="nvim"
fi

# Open vim with readonly mode just to execute all *.vader tests.
$VIM_EXE -Nu minimal_vimrc -R "+Vader! $1"
