export AMD_VULKAN_ICD=RADV
export EDITOR=nvim
export VISUAL=nvim
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
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
. "$HOME/.cargo/env"
