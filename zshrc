# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "chrishrb/zsh-kubectl"
plug "zap-zsh/magic-enter"
plug "zap-zsh/sudo"
plug "zap-zsh/web-search"

#web seach
plugins=( ... web-search)


[[ -s /home/alexpad/.autojump/etc/profile.d/autojump.sh ]] && source /home/alexpad/.autojump/etc/profile.d/autojump.sh
#[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
#[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
autoload -U compinit && compinit -u


#nove
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"


#fasd
    # function to execute built-in cd
    fasd_cd() {
      if [ $# -le 1 ]; then
        fasd "$@"
      else
        local _fasd_ret="$(fasd -e echo "$@")"
        [ -z "$_fasd_ret" ] && return
        [ -d "$_fasd_ret" ] && cd "$_fasd_ret" || echo "$_fasd_ret"
      fi
    }
    alias c='fasd_cd -d' # `-d' option present for bash completion

# Load and initialise completion system
autoload -Uz compinit
compinit
#. /usr/share/autojump/autojump.sh
source <(fzf --zsh)
# fzf
export FZF_DEFAULT_COMMAND='fd --type f --color=never --hidden'
export FZF_DEFAULT_OPTS='--no-height --color=bg+:#343d46,gutter:-1,pointer:#ff3c3c,info:#0dbc79,hl:#0dbc79,hl+:#23d18b'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"

export FZF_ALT_C_COMMAND='fd --type d . --color=never --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

# MANPAGER
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

export LANG="C.UTF-8"

# if [[ $(command -v keychain) && -e ~/.ssh/id_rsa ]]; then
  # eval `keychain --eval --quiet id_rsa`
# fi

if [[ $(command -v keychain) && -e ~/.ssh/id_ed25519 ]]; then
  eval `keychain --eval --quiet id_ed25519`
fi

if [ $(command -v direnv) ]; then
  export DIRENV_LOG_FORMAT=
  eval "$(direnv hook zsh)"
fi

# starship
if [ $(command -v starship) ]; then
  eval "$(starship init zsh)"
fi

if [ $(command -v doppler) ]; then
  doppler configure flags disable analytics --silent 2>/dev/null || true
  doppler configure flags disable env-warning --silent 2>/dev/null || true
fi

# vim & nvim
if [[ $(command -v vim) && ! $(alias vim >/dev/null 2>&1) ]]; then
  export EDITOR=$(which vim)
  alias v=$EDITOR
  alias vi=$EDITOR
fi

if [ $(command -v nvim) ]; then
  export EDITOR=$(which nvim)
  alias vim=$EDITOR
fi

alias v=$EDITOR
alias vi=$EDITOR

export SUDO_EDITOR=$EDITOR
export VISUAL=$EDITOR

# stow (th stands for target=home)
stowth() {
  stow -vSt ~ $1
}

unstowth() {
  stow -vDt ~ $1
}

diy-install() {
  wget -q https://script.install.devinsideyou.com/$1
  sudo chmod +x $1 && ./$1 $2 $3
}

up_widget() {
  BUFFER="cd .."
  zle accept-line
}

zle -N up_widget
bindkey "^\\" up_widget

which-gc() {
  jcmd $1 VM.info | grep -ohE "[^\s^,]+\sgc"
}

docker-armageddon() {
  docker stop $(docker ps -aq) # stop containers
  docker rm $(docker ps -aq) # rm containers
  docker network prune -f # rm networks
  docker rmi -f $(docker images --filter dangling=true -qa) # rm dangling images
  docker volume rm $(docker volume ls --filter dangling=true -q) # rm volumes
  docker rmi -f $(docker images -qa) # rm all images
}

nix-prefetch-sri() {
  nix-prefetch-url "$1" | xargs nix hash convert --hash-algo sha256 --to sri
}

nix-prefetch-bloop() {
  local version="$1"

  nix-prefetch-sri https://github.com/scalacenter/bloop/releases/download/v$version/bloop-x86_64-pc-linux
  echo
  nix-prefetch-sri https://github.com/scalacenter/bloop/releases/download/v$version/bloop-x86_64-apple-darwin
  echo
  nix-prefetch-sri https://github.com/scalacenter/bloop/releases/download/v$version/bloop-aarch64-apple-darwin
}

# source global settings
if [ -f "$HOME/.bash_aliases" ] ; then
  source "$HOME/.bash_aliases"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f "$HOME/.p10k.zsh" ]] || source "$HOME/.p10k.zsh"

# source local settings
if [ -f "$HOME/.local/.zshrc" ] ; then
  source "$HOME/.local/.zshrc"
fi

if [ -f "$HOME/.local/.bash_aliases" ] ; then
  source "$HOME/.local/.bash_aliases"
fi
