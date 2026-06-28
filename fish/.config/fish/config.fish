set -gx PATH $HOME/brew/bin $HOME/.local/bin $PATH
set -gx VISUAL nvim
set -gx MANPAGER "nvim +Man!"
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_greeting ''

pyenv init - fish | source

if status is-interactive
  set -g CDHISTFILE "$HOME/.cd_history"
  set -g EDHISTFILE "$HOME/.ed_history"
  set -g FZZYPICKER fzy
  set -g COMPILER tsc
  set -g EDITOR ef

  function cd --description "cd & store pwd in .cd_history"
    builtin cd $argv
    and echo $PWD >> $CDHISTFILE
  end

  function ef --description "edit file"
    command nvim $argv 
    and echo (realpath $argv[1] | sed 's/:.*$//') >> $EDHISTFILE
  end

  function rd --description "recent directories"
    set -l dir (tail -r $CDHISTFILE | awk '$0 != ENVIRON["PWD"] && !seen[$0]++' | $FZZYPICKER --p='Recent directories:')

    test -n "$dir"
    and cd "$dir"
  end

  function rf --description "recent files"
    while true
      set -l file (tail -r $EDHISTFILE | awk '!seen[$0]++' | $FZZYPICKER --p='Recent files:')

      test -z "$file"
      and break

      $EDITOR "$file"
    end
  end

  function cf --description "current files"
    while true
      set -l file (fd --hidden --color=never --type f --exclude .git -X stat -f='%m %N' | sort -r | cut -d' ' -f2- | sed 's|^\./||' | $FZZYPICKER --p='Files:')

      test -z "$file"
      and break

      $EDITOR "$file"
    end
  end

  function bd --description "browse directories"
    set -l pth
    set -l nxt

    if test -d "$argv[1]"
      set pth (realpath "$argv[1]")
    else
      set pth (realpath .)
    end

    while test -n "$pth"
      set nxt (ls -1paa "$pth" | tail -n +2 | fzy -p "$pth/")

      if test -z "$nxt"
        cd "$pth"
        break
      else if test -d "$pth/$nxt"
        set pth (realpath "$pth/$nxt")
      else
        break
      end
    end
  end

  function xc --description "execute compilation"
    while true
      set -l file
      set -l pth
      set -l err

      if test "$COMPILER" = gcc
        set file (gcc -fno-caret-diagnostics $argv 2>&1 | fzy)
      else if test "$COMPILER" = tsc
        set file (tsc --pretty false $argv | sed 's/(\([0-9]*\),\([0-9]*\)):/:\1:\2:/' | fzy)
      else
        echo "I should probably add support for $COMPILER in my script"
        break
      end

      set pth (echo $file | cut -d: -f1-3)
      set err (echo $file | cut -d: -f4- | sed "s/'//g")

      test -z "$pth"
      and break

      $EDITOR "$pth" -c "echomsg '$err'"
    end
  end

  function ss --description "search string"
    while true
      set -l file (rg --vimgrep --hidden --no-heading --smart-case $argv | fzy --lines=15 --p='Search:')

      test -z "$file"
      and break

      $EDITOR (echo "$file" | cut -d: -f1-3)
    end
  end

  function tf --description "touch file"
    touch $argv
    $EDITOR $argv
  end

  function rf --description "remove file"
    while true
      set -l file (fd --hidden --color=never --type f --exclude .git -X stat -f='%m %N' | sort -r | cut -d' ' -f2- | sed 's|^\./||' | $FZZYPICKER --p='Remove Files:')

      test -z "$file"
      and break

      rm "$file"
    end
  end

  function mf --description "move file"
    while true
      set -l file (fd --hidden --color=never --type f --exclude .git -X stat -f='%m %N' | sort -r | cut -d' ' -f2- | sed 's|^\./||' | $FZZYPICKER --p='Rename Files:')

      test -z "$file"
      and break

      read -P "Rename: " -c "$file" name
      test -n "$name"
      and mv "$file" "$name"
    end
  end

  function gf --description "git files"
    while true
      set -l file (git status --porcelain | awk '{print $2}' | xargs -r stat -f='%m %N' 2>/dev/null | sort -rn | cut -d' ' -f2- | $FZZYPICKER --lines=15 --p='Git Changes:')

      test -z "$file"
      and break

      $EDITOR "$file"
    end
  end

  function ga --description "git add file"
    while true
      set -l file (git status --porcelain | awk '{print $2}' | xargs -r stat -f='%m %N' 2>/dev/null | sort -rn | cut -d' ' -f2- | $FZZYPICKER --lines=15 --p='Stage File:')

      test -z "$file"
      and break

      git add -p "$file"
    end
  end

  function gc --description "git commits"
    while true
      set -l commit (git log --oneline | $FZZYPICKER --lines=15 --p='Git Commits:' | awk '{print $1}')

      test -z "$commit"
      and break

      git show "$commit"
    end
  end

  function he --description "help"
      echo "tf - touch file"
      echo "rf - remove file"
      echo "mf - move file"
      echo "ef - edit file"
      echo "rd - recent directories"
      echo "bd - browse directories"
      echo "rf - recent files"
      echo "bf - browse files"
      echo "xc - execute compilation with $COMPILER"
      echo "ss - search string"
      echo "gf - git files"
      echo "ga - git add file"
      echo "gc - git commits"
  end
end
