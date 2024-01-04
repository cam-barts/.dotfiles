# If zsh is acting up, load this and the one at the bottom
# zmodload zsh/zprof

#If If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
# export ZSH="$HOME/.oh-my-zsh"


# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
DISABLE_LS_COLORS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git docker docker-compose alias-finder zsh-autosuggestions)

plugins=(zsh-autosuggestions)
# source $ZSH/oh-my-zsh.sh

source ~/.profile
# source ~/goto.sh
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/nux/.config/broot/launcher/bash/br

# autoload -Uz compinit
#
# zstyle ':completion:*' menu select
# zmodload zsh/complist
# compinit

autoload -Uz colors && colors

# vi mode
bindkey -v
export KEYTIMEOUT=1


# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line


## Useful aliases
# Replace ls with exa
alias ls='exa -al --color=always --group-directories-first' # preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.="exa -a | egrep '^\.'"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias g="goto"
# Replace some more things with better alternatives
alias cat='bat'


alias open='xdg-open'
# Common use
alias grubup="sudo update-grub"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info
alias please='sudo'
# alias tb='nc termbin.com 9999'
#get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"
alias hosts="hosts --auto-sudo"
# alias cp="fcp"

# Arch Common
alias upd='sudo reflector --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && cat /etc/pacman.d/mirrorlist && paru -Syyu'
alias aup="pamac upgrade --aur"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias big="expac -H M '%m\t%n' | sort -h | nl"              # Sort installed packages according to size in MB (expac must be installed)
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'			# List amount of -git packages


# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

alias paru="paru --bottomup"

#Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias docker-cleanup='docker container prune -f && docker image prune -a'

#Recent Installed Packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

ZSH_ALIAS_FINDER_AUTOMATIC=true
alias alias-finder="alias-finder -l"

path+=("$HOME/.local/bin")
path+=("$HOME/.local/share/gem/ruby/3.0.0/bin")
path+=("$XDG_DATA_HOME/cargo/bin")

alias Just="just --justfile ~/.user.justfile --working-directory ."

# alias Mask="mask --maskfile ~/.config/maskfile.md"
function Mask() {
  if [ $# -eq 0 ]; then
    mask --maskfile ~/.config/maskfile.md --help
  else
    mask --maskfile ~/.config/maskfile.md "$@"
  fi
}
alias idea="nvim '/home/nux/ObsVaults/Nux/00 Meta/✏Workbench.md'"
alias history="history keep -1 | tac | cut -d' ' -f3- | fzf"
alias esconfig="nvim ~/.dotfiles/espanso/.config/espanso/match/ && espanso restart"
alias nvimconfig="nvim ~/.config/nvim"
alias rm_pkg="paru -Qei | awk '/^Name/{name=\$3} /^Installed Size/{print \$4\$5, name}' | sort -h --reverse| fzf -m | cut -d' '  -f2 | xargs paru -Rns -"
alias dust="br -w"

# alias chatblade="chatblade --openai-api-key $(keyring get OpenAI camerond.barts@gmail.com)"


export HISTFILE="$XDG_STATE_HOME"/zsh/history


rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	xdg-open "$file"
}


eval "$(starship init zsh)"
# zprof
