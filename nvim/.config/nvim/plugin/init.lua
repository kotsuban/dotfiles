-- Global Settings.
vim.g.mapleader = " "
vim.o.relativenumber = true
vim.o.number = true
vim.o.statuscolumn = '%C%s%=%{v:relnum?v:relnum:v:lnum} '
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.winborder = "rounded"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.updatetime = 250
vim.opt.wildmode = 'full'
vim.o.wildignore = "*/node_modules/*,*/dist/*,*/build/*,*.git,*.cache,*/static/*,*/__pycache__/*,*.venv"
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
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
vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.o.complete = "o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.autocomplete = false
vim.o.laststatus = 3
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.cmd('filetype indent on')
vim.opt.autoindent = true

-- Plugins.
vim.pack.add({ "https://github.com/kotsuban/nekomi.nvim" })
vim.cmd.colorscheme("nekomi")

vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive"
}, { load = true })
require("gitsigns").setup({
  signcolumn = false,
  numhl = true,
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

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    return vim.api.nvim_buf_get_name(0)
  end
end

require("oil").setup({
  default_file_explorer = true,
  columns = {
    "icon",
    "size",
  },
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    is_hidden_file = function()
      return false
    end,
  },
  win_options = {
    winbar = "%!v:lua.get_oil_winbar()",
  },
})
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "_", "<cmd>Oil .<cr>", { desc = "Open root directory" })
vim.keymap.set("n", "+", "<cmd>Oil ~/Downloads/<cr>", { desc = "Open downloads directory" })

vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("mason").setup()

-- Helpers.
function _G.find(cmdarg)
  local input = tostring(cmdarg or "")
  local base_dir = nil
  local needle = input

  if vim.startswith(input, "/") or vim.startswith(input, "~") then
    local expanded = vim.fn.expand(input)
    local stat = vim.uv.fs_stat(expanded)

    if input:sub(-1) == "/" or (stat and stat.type == "directory") then
      base_dir = expanded
      needle = ""
    else
      base_dir = vim.fn.fnamemodify(expanded, ":h")
      needle = vim.fn.fnamemodify(expanded, ":t")
    end
  end

  local output = base_dir
      and vim.fn.systemlist("fd -d=1 --color=never --type f --type d --exclude .git . " .. vim.fn.shellescape(base_dir))
      or vim.fn.systemlist "fd --hidden --color=never --type f --exclude .git"

  return needle == "" and output or vim.fn.matchfuzzy(output, needle)
end

vim.o.findfunc = "v:lua.find"

local grep_under_cursor = function()
  vim.cmd('silent grep "' .. vim.fn.expand("<cword>") .. '" | copen')
end

local toggle_quickfix = function()
  local is_open = vim.iter(vim.fn.getwininfo()):any(function(win) return win.quickfix == 1 end)
  return is_open and vim.cmd("cclose") or vim.cmd("copen")
end

-- Bindings.
vim.keymap.set("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix buffer" })
vim.keymap.set({ "n" }, "<Esc><Esc>", ":bdelete<CR>", { desc = "Close current window" })
vim.keymap.set("v", "v", "g_", { noremap = true, desc = "Visual to end of line (non-newline)" })
vim.keymap.set("n", "<leader>`", "<C-^>", { noremap = true, desc = "Swap with previous file" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload nvim config" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected code down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected code up" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("n", "<leader>s", 'q:isilent grep  |cope<left><left><left><left><left><left>',
  { desc = "Search via grep" })
vim.keymap.set("n", "<leader>w", grep_under_cursor, { desc = "Search current word via grep" })
vim.keymap.set("n", "<leader>f", ":find ", { desc = "Find file" })
vim.keymap.set("n", "<leader>b", ":buffer ", { desc = "Open buffers" })
vim.keymap.set("n", "<leader>g", '<cmd>G<CR>', { desc = "Open git fugitive" })
vim.keymap.set("n", "<leader><leader>", ':make ', { desc = "Build via compiler" })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<M-k>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<M-j>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<M-h>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<M-l>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

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

  return " " .. branch
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
  "%{v:lua.directory()}",
  "%#StatusLineWhite#",
  " on ",
  "%#StatusLineBlue#",
  "%{v:lua.branch()} ",
}

-- Lsp & Treesitter.
vim.treesitter.language.register("typescript", { 'ts' }) -- https://github.com/nvim-treesitter/nvim-treesitter/blob/4967fa48b0fe7a7f92cee546c76bb4bb61bb14d5/plugin/filetypes.lua#L62
vim.treesitter.language.register("javascript", { 'javascriptreact', 'ecma', 'ecmascript', 'jsx', 'js' })
vim.treesitter.language.register("tsx", { 'typescriptreact', 'typescript.tsx' })

vim.lsp.enable({ "clangd", "lua_ls", "ts_ls", "eslint" }) -- https://github.com/neovim/nvim-lspconfig
vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and client.server_capabilities.semanticTokensProvider then
      client.server_capabilities.semanticTokensProvider = nil
    end

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>l", vim.diagnostic.setloclist, opts)
  end,
})

-- Diagnostics.
vim.diagnostic.config({
  signs = false,
  virtual_text = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
})

local ns = vim.api.nvim_create_namespace("make-diagnostics")

local function quickfix_to_diagnostics()
  local qf = vim.fn.getqflist()
  local diagnostics = {}

  for _, item in ipairs(qf) do
    if item.bufnr > 0 then
      diagnostics[item.bufnr] = diagnostics[item.bufnr] or {}

      table.insert(diagnostics[item.bufnr], {
        lnum = (item.lnum or 1) - 1,
        col = (item.col or 1) - 1,
        message = item.text or "",
        severity = vim.diagnostic.severity.ERROR,
        source = "make",
      })
    end
  end

  for bufnr, diags in pairs(diagnostics) do
    vim.diagnostic.set(ns, bufnr, diags, {})
  end
end

-- Autocommands.
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("QuickFixCmdPost", { -- Populate diagnostics with errors from quickfix list.
  pattern = "make",
  callback = function()
    vim.diagnostic.reset(ns)
    quickfix_to_diagnostics()
  end,
})

vim.api.nvim_create_autocmd("FileType", { -- Run treesitter.
  group = augroup,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end
})

vim.api.nvim_create_autocmd("TextYankPost", { -- Highlight yanked text.
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
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

vim.api.nvim_create_autocmd("FileType", { -- Close quickfix menu after selecting a choice.
  group = augroup,
  pattern = { "qf" },
  command = [[nnoremap <buffer> <CR> <CR>:cclose<CR>]]
})

vim.api.nvim_create_autocmd("CmdlineChanged", { -- Mini fuzzy finder.
  pattern = { '*' },
  group = augroup,
  callback = function(ev)
    local function is_enabled()
      local cmd = vim.fn.split(vim.fn.getcmdline(), ' ')[1]
      return cmd == 'find' or cmd == 'buffer' or cmd == 'help'
    end

    if ev.event == 'CmdlineChanged' then
      vim.opt.wildmode = 'full'
    end

    if ev.event == 'CmdlineChanged' and is_enabled() then
      vim.opt.wildmode = 'noselect:lastused,full'
      vim.fn.wildtrigger()
    end
  end
})

vim.api.nvim_create_autocmd("BufReadCmd", { -- Preview images.
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
  group = augroup,
  callback = function(args)
    local image_dir = vim.fn.fnamemodify(args.file, ":h")
    vim.fn.jobstart({ "viu", args.file }, { term = true, cwd = image_dir })
    vim.api.nvim_buf_set_name(args.buf, args.file)
  end
})
