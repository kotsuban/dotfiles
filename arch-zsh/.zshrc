export PATH=$PATH
export LANG=en_US.UTF-8
export EZA_CONFIG_DIR=$HOME/.config/eza
export KEYTIMEOUT=1

alias ls='eza --icons -a --sort=type'
alias yayup='yay -Syu'
alias sss='/home/ant/dotfiles/scripts/fastmux.sh'

bindkey -v

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source <(fzf --zsh)

eval "$(starship init zsh)"
