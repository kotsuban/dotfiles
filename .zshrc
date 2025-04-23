export PATH=$HOME/brew/bin:$PATH
export LANG=en_US.UTF-8
export EZA_CONFIG_DIR=$HOME/.config/eza

alias ls='eza --icons -a --sort=type'

# vi mode setup
bindkey -v

# Fix to be able to use backspace after vi mode.
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
