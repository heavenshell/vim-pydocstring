#!/bin/sh
: "${VIM_EXE:=vim}"

# Open Vim just to execute all *.vader tests.
$VIM_EXE -Nu vimrc -c 'Vader! *.vader'
