#!/usr/bin/env bash
#

#
# If not running interactively, don't do anything
#
case $- in
    *i*) ;;
      *) return;;
esac

#
# History Management:
#  - don't put duplicate lines
#  - erase duplicate lines
#
HISTCONTROL=ignoredups:erasedups

#  - append to the history file, don't overwrite it
#  - check the window size after each command and, if necessary,
#     update the values of lines and columns
#
shopt -s histappend
shopt -s checkwinsize

#  - setting history length
#
HISTSIZE=100000
HISTFILESIZE=100000

#  - saving and reloading the history after each command finishes
#
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#
# Useful settings (if you are in Bash under WSL)
#
umask 022

if [ -f ~/.bash_aliases ]
then
    source ~/.bash_aliases
fi
if [ -f ~/.bash_customs ]
then
    source ~/.bash_customs
fi
if [ -f ~/.bash_exports ]
then
    source ~/.bash_exports
fi
if [ -f ~/.bash_functions ]
then
    source ~/.bash_functions
fi

#
# Print a random phrase when the terminal is
#  opened and all scripts have been loaded
#
# Some other "cows" here: /usr/share/cowsay/cows
#  -f <cow_name>
#  -W <max_columns>
#  -b / -d / -g / -p / -s / -t / -w / -y
#
fortune -as | cowthink -n -$(expr substr "-bdgpstwy" $(shuf -i1-9 -n1) 1)
