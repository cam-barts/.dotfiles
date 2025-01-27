#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
eval "$(starship init bash)"

export HISTFILE="${XDG_STATE_HOME}"/bash/history
# Source goto
[[ -s "/usr/local/share/goto.sh" ]] && source /usr/local/share/goto.sh

. "$HOME/.cargo/env"

source /home/nux/.config/broot/launcher/bash/br

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

# Created by `pipx` on 2023-12-07 00:42:22
export PATH="$PATH:/home/nux/.local/bin"

complete -C /home/nux/.local/bin/mc mc
