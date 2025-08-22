vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.winborder = "rounded"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 500
vim.o.wildmode = "longest:full,full"
vim.o.wildignore = "*/node_modules/*,*/dist/*,*/static/*,*/__pycache__/*,*.log,*.git,*.venv,*.cache"
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
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)
vim.o.complete = ".,o"
vim.o.completeopt = "fuzzy,menuone,noselect"
vim.o.autocomplete = true
vim.o.laststatus = 3

-- Helpers.
local generate_path = function()
  local ignore = { "node_modules", "dist", "build", ".git", ".cache", "static", "__pycache__", ".venv" }

  local handle = vim.loop.fs_scandir(vim.loop.cwd())
  local dirs = { ".,," }
  if handle then
    while true do
      local name, t = vim.loop.fs_scandir_next(handle)
      if not name then break end
      if t == "directory" and not vim.tbl_contains(ignore, name) then
        table.insert(dirs, name .. "/**")
      end
    end
  end

  return table.concat(dirs, ",")
end

vim.o.path = generate_path()

local open_oldfiles = function()
  local cwd = vim.loop.cwd()
  local current_file = vim.fn.expand("%:p")
  local items, seen = {}, {}

  local function get_cursor_pos(bufnr)
    local mark = vim.api.nvim_buf_get_mark(bufnr, '"')
    return (mark[1] > 0) and mark[1] or 0, (mark[2] > 0) and mark[2] or 0
  end

  local function add_file(file, bufnr)
    if not file or file == "" or file == current_file or seen[file] then return end
    if vim.fn.filereadable(file) == 0 or not vim.startswith(file, cwd) then return end
    seen[file] = true
    bufnr = bufnr or vim.fn.bufadd(file)
    vim.fn.bufload(bufnr)
    local lnum, col = get_cursor_pos(bufnr)
    items[#items + 1] = { filename = file, lnum = lnum, col = col }
  end

  for _, line in ipairs(vim.split(vim.fn.execute(":buffers! t"), "\n")) do
    local bufnr = tonumber(line:match("%s*(%d+)"))
    if bufnr then add_file(vim.api.nvim_buf_get_name(bufnr), bufnr) end
  end

  for _, file in ipairs(vim.v.oldfiles) do
    add_file(file)
  end

  vim.fn.setqflist(items, "r")
  vim.cmd("copen")
end

local grep_under_cursor = function()
  local word = vim.fn.expand("<cword>")
  vim.cmd('silent grep "' .. word .. '" | copen')
end

local toggle_scratch_buffer = function()
  local uv = vim.uv or vim.loop
  local cwd = vim.uv.cwd()
  local scratch_dir = vim.fn.stdpath("data") .. "/scratch"
  local scratch_file = scratch_dir .. "/" .. cwd:gsub("^/", ""):gsub("/", "%%") .. ".md"
  vim.fn.mkdir(scratch_dir, "p")
  local buf

  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == cwd then
      buf = b
      break
    end
  end

  if not buf then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, cwd)
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"

    if uv.fs_stat(scratch_file) then
      local lines = vim.fn.readfile(scratch_file)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    local augroup = vim.api.nvim_create_augroup("scratch_autosave_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ "BufLeave", "BufHidden" }, {
      group = augroup,
      buffer = buf,
      callback = function()
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.fn.writefile(content, scratch_file)
      end,
    })
  end

  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd("b#")
    return
  end

  vim.api.nvim_win_set_buf(0, buf)
end

-- Keymaps.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Exit from search mode" })
vim.keymap.set({ "n", "v", "i" }, "<Esc><Esc>", ":silent! close<CR>", { desc = "Close current window" })
vim.keymap.set("v", "v", "g_", { noremap = true, desc = "Visual to end of line (non-newline)" })
vim.keymap.set("n", "<leader>`", "<C-^>", { noremap = true, desc = "Swap with previous file" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload nvim config" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected code down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected code up" })
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("n", "<leader>s", 'q:isilent grep "test" | copen', { desc = "Search via grep" })
vim.keymap.set("n", "<leader>sw", grep_under_cursor, { desc = "Search current word via grep" })
vim.keymap.set("n", "<leader><leader>", ":find ", { desc = "Find file" })
vim.keymap.set("n", "<leader>fr", open_oldfiles, { desc = "Open old files" })
vim.keymap.set("n", "<leader>.", toggle_scratch_buffer, { desc = "Open scratch buffer" })
vim.keymap.set("n", "<leader>gg", '<cmd>G<CR>', { desc = "Open git fugitive" })
vim.keymap.set(
  "v",
  "<leader>r",
  '"hy:%s/<C-r>h//g<left><left>',
  { desc = "Replace all instances of highlighted words" }
)

-- Statusline.
local colors = require("catppuccin.palettes").get_palette "mocha"

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
  local git_dir = vim.fn.finddir(".git", ".;")
  if git_dir == "" then
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

-- Lsp.
vim.diagnostic.config({
  signs = false,
  virtual_text = {
    prefix = "",
  },
  underline = true,
  update_in_insert = true,
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

vim.lsp.enable({ "clangd", "lua_ls", "ts_ls", "eslint", "stylelint-lsp", "somesass_ls" }) -- https://github.com/neovim/nvim-lspconfig

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ck", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, opts)
  end,
})

local augroup = vim.api.nvim_create_augroup("UserConfig", {})

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

vim.api.nvim_create_autocmd( -- Close quickfix menu after selecting a choice.
  "FileType", {
    group = augroup,
    pattern = { "qf" },
    command = [[nnoremap <buffer> <CR> <CR>:cclose<CR>]]
  })
