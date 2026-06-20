-- Global Settings.
vim.g.mapleader = " "
vim.o.relativenumber = true
vim.o.number = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.winborder = "rounded"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.updatetime = 250
vim.o.wildmode = 'full'
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.wrap = false
vim.o.swapfile = false
vim.o.inccommand = "nosplit"
vim.o.jumpoptions = "view"
vim.o.linebreak = true
vim.o.confirm = true
vim.o.complete = "o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.cursorline = true
vim.o.autocomplete = false
vim.o.laststatus = 3
vim.o.autoindent = true
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.cmd('filetype indent on')

-- Plugins.
vim.pack.add({
  "https://github.com/kotsuban/nekomi.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/wsdjeg/vim-fetch"
})

vim.cmd.colorscheme("nekomi")

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}
require('nvim-treesitter').install { 'typescript', 'javascript', 'tsx', 'html', 'scss', 'zsh', 'bash', 'ledger' }

require("gitsigns").setup({
  signcolumn = true,
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    vim.keymap.set("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "Jump to next git [c]hange", buffer = bufnr })
    vim.keymap.set("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "Jump to previous git [c]hange", buffer = bufnr })
    vim.keymap.set("n", "<leader>p", gitsigns.preview_hunk, { desc = "git [p]review hunk", buffer = bufnr })
  end,
})

require("mason").setup()

-- Bindings.
vim.keymap.set({ "n" }, "<Esc><Esc>", ":bdelete<CR>", { desc = "Close current window" })
vim.keymap.set("v", "v", "g_", { noremap = true, desc = "Visual to end of line (non-newline)" })
vim.keymap.set("n", "<leader>`", "<C-^>", { noremap = true, desc = "Swap with previous file" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload nvim config" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected code down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected code up" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("n", "<leader>g", '<cmd>G<CR>', { desc = "Open git fugitive" })

-- Statusline.
local colors = require("nekomi").colors
vim.api.nvim_set_hl(0, "StatusLineBlue", { fg = colors.blue, bold = true })
vim.api.nvim_set_hl(0, "StatusLineMauve", { fg = colors.mauve, bold = true })
vim.api.nvim_set_hl(0, "StatusLineWhite", { fg = colors.white, bold = false })
vim.api.nvim_set_hl(0, "StatusLineYellow", { fg = colors.yellow, bold = false })
vim.api.nvim_set_hl(0, "StatusLineRed", { fg = colors.red, bold = false })
vim.api.nvim_set_hl(0, "StatusLineTeal", { fg = colors.teal, bold = false })
vim.api.nvim_set_hl(0, "StatusLineSky", { fg = colors.sky, bold = false })
vim.api.nvim_set_hl(0, "StatusLineGreen", { fg = colors.green, bold = false })

_G.directory = function()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end
_G.diagnostics = function(symbol, type)
  local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[type] })
  return count > 0 and symbol .. count .. " " or ""
end
_G.diff = function(symbol, type)
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns or gitsigns.head == '' then
    return ''
  end
  return gitsigns[type] and gitsigns[type] > 0 and (symbol .. gitsigns[type] .. " ") or ""
end
_G.on = function()
  local git_dir = vim.fs.find(".git", { upward = true, type = "directory" })[1]
  if git_dir == "" or git_dir == nil then
    return ""
  end

  return "on "
end
_G.branch = function()
  local git_dir = vim.fs.find(".git", { upward = true, type = "directory" })[1]
  if git_dir == "" or git_dir == nil then
    return ""
  end

  local head_file = git_dir .. "/HEAD"
  local f = io.open(head_file)
  if not f then return "" end
  local head = f:read("*l")
  f:close()

  local branch = head:match("ref: refs/heads/(.+)")
  if not branch then
    branch = head:sub(1, 6)
  end

  return branch .. " "
end

vim.o.statusline = table.concat {
  "%#StatusLineBlue#",
  " %t %h%m%r ",
  "%#StatusLineGreen#",
  "%{v:lua.diff('+', 'added')}",
  "%#StatusLineYellow#",
  "%{v:lua.diff('~', 'changed')}",
  "%#StatusLineRed#",
  "%{v:lua.diff('-', 'removed')}",
  "%=",
  "%#StatusLineTeal#",
  "%{v:lua.diagnostics('󰌶 ', 'HINT')}",
  "%#StatusLineSky#",
  "%{v:lua.diagnostics('󰋽 ', 'INFO')}",
  "%#StatusLineRed#",
  "%{v:lua.diagnostics('󰅚 ', 'ERROR')}",
  "%#StatusLineYellow#",
  "%{v:lua.diagnostics('󰀪 ', 'WARN')}",
  "%#StatusLineMauve#",
  "%{v:lua.directory()} ",
  "%#StatusLineWhite#",
  "%{v:lua.on()}",
  "%#StatusLineBlue#",
  "%{v:lua.branch()}",
}

-- Lsp.
vim.lsp.enable({ "clangd", "lua_ls", "ts_ls", "eslint" }) -- https://github.com/neovim/nvim-lspconfig
vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local opts = { buffer = ev.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
  end,
})

-- Autocommands.
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("FileType", { -- Run treesitter.
  group = augroup,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end
})

vim.api.nvim_create_autocmd("TextYankPost", { -- Highlight yanked text.
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", { -- Return to last edit position when opening files.
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", { -- Format on save.
  group = augroup,
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
