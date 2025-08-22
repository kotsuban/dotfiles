export PATH=$HOME/brew/bin:$PATH
export LANG=en_US.UTF-8
export EZA_CONFIG_DIR=$HOME/.config/eza
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

alias ls='eza --icons -a --sort=type'

bindkey -v

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

function zvm_config() {
  ZVM_VI_HIGHLIGHT_BACKGROUND=black
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

eval "$(starship init zsh)"
