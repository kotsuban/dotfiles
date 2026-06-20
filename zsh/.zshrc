export PATH=$HOME/brew/bin:$HOME/.local/bin:$PATH
export LANG=en_US.UTF-8
export EZA_CONFIG_DIR=$HOME/.config/eza
export EDITOR=e
export COMPILER=gcc
export VISUAL=nvim
export MANPAGER="nvim +Man!"
CDHISTFILE="$HOME/.cd_history"
EDHISTFILE="$HOME/.ed_history"
FZZYPICKER="fzy"

bindkey -v

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

eval "$(starship init zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

cd() {
  builtin cd "$@" && printf '%s\n' "$PWD" >> "$CDHISTFILE"
}

e() {
  command nvim "$@" && printf '%s\n' "$1" >> "$EDHISTFILE"
}

# Open recent directories.
c() {
  cd "$(tail -r "$CDHISTFILE" | awk '$0 != ENVIRON["PWD"] && !seen[$0]++' | "$FZZYPICKER" --p='Recent directories:')"
}

# Open recent files.
f() {
  while true; do
    local file="$(tail -r "$EDHISTFILE" | awk '$0 != ENVIRON["PWD"] && !seen[$0]++' | "$FZZYPICKER" --p='Recent files:')"
    [ -z "$file" ] && break
    $EDITOR "$file"
  done
}

# Open files (cwd).
o() {
  while true; do
    local file="$(fd --hidden --color=never --type f --exclude .git -X stat -f='%m %N' | sort -r | cut -d' ' -f2- | sed 's|^\./||' | "$FZZYPICKER" --p='Files:')"
    [ -z "$file" ] && break
    $EDITOR "$file"
  done
}

# Browse directories.
b() {
  local pth
  local nxt

  if [[ -d "$1" ]]; then
    pth="$(realpath $1)"
  else
    pth="$(realpath .)"
  fi

  while [[ -n "$pth" ]]
  do
    nxt=$(ls -1paa "$pth" | tail -n +2 | fzy -p "$pth/")

    if [[ -z "$nxt" ]]; then # Empty.
      cd "$pth"
      break
    elif [[ -d "$pth/$nxt" ]]; then # Directory.
      pth=$(realpath "$pth/$nxt")
    else
      break
    fi
  done
}

# Compile.
x() {
  while true; do
    local file
    local pth
    local err

    if [[ $COMPILER = "gcc" ]]; then
      file="$(gcc -fno-caret-diagnostics $@ 2>&1 | fzy)"
    elif [[ $COMPILER = "tsc" ]]; then
      file="$(tsc --pretty false $@ | sed 's/(\([0-9]*\),\([0-9]*\)):/:\1:\2:/' | fzy)"
    else
      echo "I should probably add support for $COMPILER in my script"
      break
    fi
    [ -z "$file" ] && break

    pth=$(echo $file | cut -d: -f1-3)
    err=$(echo $file | cut -d: -f4- | sed "s/'//g")

    $EDITOR "$pth" -c "echomsg '$err'"
  done
}

# Search.
s() {
  while true; do
    local file="$(rg --vimgrep --hidden --no-heading --smart-case $@ | fzy --lines=15 --p='Search:')"
    [ -z "$file" ] && break

    $EDITOR "$(echo $file | cut -d: -f1-3)"
  done
}
