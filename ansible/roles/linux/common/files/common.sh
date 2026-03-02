#!/bin/sh
# ANSIBLE MANAGED: DO NOT EDIT MANUALLY

# file copied in /etc/profile.d/ by conf-utils.sh
# aliases for all users (included root)

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias l='ls '
alias ll='ls -alF'
alias la='ls -A'

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[36m\]\w\[\033[00m\]\$ '