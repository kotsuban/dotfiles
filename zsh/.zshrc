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

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(starship init zsh)"
