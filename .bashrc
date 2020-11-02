#!/bin/bash

#
# Load dotfiles
# Files are named: .dotfiles-*
# ---------------------------------------------------
for file in ~/.dotfiles-{aliases,functions,local-settings}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

#
# Git Auto-completion
# ---------------------------------------------------
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

#
# Prompt
# ---------------------------------------------------

# Starship.rs
eval "$(starship init bash)"

# parse_git_branch() {
#   git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
# }

# PS1 without hostname
# PS1="\n\[\e[36m\]\u \[\033[38;5;11m\]\[$(tput bold)\]\w\[$(tput sgr0)\]\[\e[m\]\[\e[32m\]\$(parse_git_branch)\[\033[00m\] : "

# PS1 with hostname and only 1 newline
# PS1="\n\[\e[36m\]\u\[\033[38;5;15m\]@\h: \[\033[38;5;11m\]\[$(tput bold)\]\w\[$(tput sgr0)\]\[\e[m\]\[\e[33m\]\$(parse_git_branch)\[\033[00m\] : "

# Default PS1 (256 Color)
# PS1="\n\[\e[36m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[37m\]\h\[\e[m\]\[\e[37m\]: \n\[\e[m\]\[\e[93m\]\w\[\e[m\] \[\e[33m\]\`parse_git_branch\`\[\e[m\] "
# IF VSCODE, CAN'T USE 256 COLORS, SO USE DIFFERENT PS1
# if [[ "$IS_VSCODE" == "true" ]]; then
#     PS1="\n\[\e[36m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[37m\]\h\[\e[m\]\[\e[37m\]: \n\[\e[m\]\[\e[33m\]\w\[\e[m\] \[\e[35m\]\`parse_git_branch\`\[\e[m\] "
# fi
# Add newline to PS1
# export PS1+=$'\n$ ';

# ############################################
