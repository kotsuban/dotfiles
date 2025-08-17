 export LANG=en_US.UTF-8
 export EZA_CONFIG_DIR=$HOME/.config/eza

 alias ls='eza --icons -a --sort=type'

 bindkey -v

 eval "$(starship init zsh)"
