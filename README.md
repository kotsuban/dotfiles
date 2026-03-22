# My dotfiles (macos)

<img width="1440" height="900" alt="image" src="https://imgur.com/Q1BN54z.png" />

## Deps
- `brew` - package manager.
- `git bob eza sk fd ripgrep starship stow tmux viu zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode` - brew formulae.
- `ghostty` - brew casks.

## Installation

Make sure you're on a `macos` branch.

To install specific config use `stow folder-name`, for example:

- `stow nvim` - install nvim config.
- `stow zsh` install config.

## Neovim related

To install LSP server:
- Copy required lsp config from `https://github.com/neovim/nvim-lspconfig/tree/master/lsp`.
- Install cli from `:Mason`.

To install Tresitter language:
- Find required parser using [luarocks](`https://luarocks.org/`).
- Clone git repo into ~/Downloads.
- Build parser using treesitter-cli `tree-sitter build --output parser.so /path/to/tree-sitter-parser`
- Copy queries `cp /path/to/tree-sitter-parser/queries/* .`
- Some languages need manual treesitter registration, see: https://github.com/nvim-treesitter/nvim-treesitter/blob/main/plugin/filetypes.lua.
