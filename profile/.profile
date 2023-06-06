# ---- Start xdg-ninja ---------
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
# ---
export AZURE_CONFIG_DIR="$XDG_DATA_HOME"/azure
export HISTFILE="${XDG_STATE_HOME}"/bash/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GOPATH="$XDG_DATA_HOME"/go
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export KDEHOME="$XDG_CONFIG_HOME"/kde
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export ZSH="$XDG_DATA_HOME"/oh-my-zsh
export OMNISHARPHOME="$XDG_CONFIG_HOME"/omnisharp
export PSQL_HISTORY="$XDG_DATA_HOME/psql_history"
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export WINEPREFIX="$XDG_DATA_HOME"/wine
export ZDOTDIR="$HOME"/.config/zsh


# ---- Previous Profile -------
export AMD_VULKAN_ICD=RADV
export EDITOR=nvim
export VISUAL=nvim
# export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export BROWSER=brave
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PYTHON_KEYRING_BACKEND=keyring.backends.SecretService.Keyring
export NMAP_PRIVILEGED="" # https://secwiki.org/w/Running_nmap_as_an_unprivileged_user
export PIPENV_VENV_IN_PROJECT=1 # https://pipenv.pypa.io/en/latest/install/#virtualenv-mapping-caveat
export BORG_PASSCOMMAND='secret-tool lookup service borg'
# export QT_STYLE_OVERRIDE=breeze
export PYTHONPATH=.
export PASTETIME=5
export GTK_THEME="sweet"
# export QT_QPA_PLATFORMTHEME=qt5ct
. "$HOME/.local/share/cargo/env"
