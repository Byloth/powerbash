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
#  - don't put lines with leading spaces
#  - erase duplicate lines
#
HISTCONTROL=ignoreboth:erasedups

#  - append to the history file, don't overwrite it
#  - check the window size after each command and, if necessary,
#     update the values of LINES and COLUMNS.
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
# Useful export (if you are in Bash under WSL)
#
if [[ -x /bin/wslpath ]]
then
    export IS_WSL_ENV=1

    #
    # Useful WSL settings
    #
    umask 022
fi

#
# Alias definitions.
# You may want to put all your additions into a separate file
#  like `~/.bash_aliases`, instead of adding them here directly.
# See `/usr/share/doc/bash-doc/examples` in the bash-doc package.
#
if [[ -f ~/.bash_aliases ]]
then
    source ~/.bash_aliases
fi
if [[ -f ~/.bash_customs ]]
then
    source ~/.bash_customs
fi
if [[ -f ~/.bash_exports ]]
then
    source ~/.bash_exports
fi
if [[ -f ~/.bash_functions ]]
then
    source ~/.bash_functions
fi

#
# Print a random phrase when the terminal is
#  opened and all scripts have been loaded.
#
_randomPhrase
