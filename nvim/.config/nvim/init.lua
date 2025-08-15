-- Settings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.pumblend = 10
vim.o.pumheight = 10
vim.o.relativenumber = true
vim.o.ruler = false
vim.o.showmode = false
vim.o.sidescrolloff = 8
vim.o.breakindent = true
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.ignorecase = true
vim.o.winborder = "rounded"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.signcolumn = "yes"
vim.o.numberwidth = 1
vim.o.conceallevel = 2
vim.o.updatetime = 200
vim.o.virtualedit = "block"
vim.o.wildmode = "longest:full,full" -- TODO Try to fix dotfiles issue (:find can't locate files under a .directory)
vim.o.wildignore = "*/node_modules/*,*/dist/*,*/static/*,*/__pycache__/*,*.log"
vim.o.winminwidth = 5
vim.o.timeoutlen = 500
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.list = true
vim.o.listchars = "tab:» ,trail:·,nbsp:␣"
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.fillchars = "foldopen:,foldclose:,fold: ,foldsep: ,diff:╱,eob: "
vim.o.foldlevel = 99
vim.o.wrap = false
vim.o.swapfile = false
vim.o.inccommand = "nosplit"
vim.o.jumpoptions = "view"
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.cursorline = true
vim.o.scrolloff = 4
vim.o.confirm = true
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.path = ".,**"
vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.schedule(function()
  vim.o.clipboard = "unnamedplus" -- Use system clipboard for all yank/paste.
end)

-- Plugins.
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
for _, file in ipairs(vim.fn.glob(plugin_dir .. "/*.lua", false, true)) do
  local name = file:match("([^/]+)%.lua$")
  if name and name ~= "init" then
    require("plugins." .. name)
  end
end

-- Helpers.
local oldfiles_list = function()
  local current_file = vim.fn.expand("%:p")
  local items = {}

  local get_cursor_pos = function(buf)
    local lnum, col = 1, 1

    local saved = vim.api.nvim_buf_get_mark(buf, '"')
    if saved[1] > 0 then
      lnum, col = saved[1], saved[2]
    end

    return lnum, col
  end

  for _, buffer in ipairs(vim.split(vim.fn.execute(":buffers! t"), "\n")) do
    local bufnr = tonumber(buffer:match("%s*(%d+)"))
    if bufnr then
      local file = vim.api.nvim_buf_get_name(bufnr)
      if #file > 0 and vim.fn.filereadable(file) == 1 and file ~= current_file then
        local lnum, col = get_cursor_pos(bufnr)

        table.insert(items, { filename = file, lnum = lnum, col = col })
      end
    end
  end

  for _, file in ipairs(vim.v.oldfiles) do
    if vim.fn.filereadable(file) == 1 and file ~= current_file then
      local buf = vim.fn.bufadd(file)
      vim.fn.bufload(buf)
      local lnum, col = get_cursor_pos(buf)

      table.insert(items, { filename = file, lnum = lnum, col = col })
    end
  end

  if #items > 0 then
    vim.fn.setqflist(items, "r")
    vim.cmd("copen")
  else
    vim.notify("No oldfiles found", vim.log.levels.WARN)
  end
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

  -- Find existing scratch buffer for this CWD
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_get_name(b) == cwd then
      buf = b
      break
    end
  end

  -- Create new scratch buffer if not found
  if not buf then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, cwd)
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"

    -- Load existing scratch file content if present
    if uv.fs_stat(scratch_file) then
      local lines = vim.fn.readfile(scratch_file)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    -- Auto-save content to file on hide/leave
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

  -- If currently viewing scratch → close it and return
  if vim.api.nvim_get_current_buf() == buf then
    vim.cmd("b#")
    return
  end

  -- Show scratch buffer in current window
  vim.api.nvim_win_set_buf(0, buf)
end

local format_buffer = function()
  vim.lsp.buf.format({ async = false })
  vim.cmd.write()
end

-- Keymaps.
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Exit from search mode" })
vim.keymap.set({ "n", "v", "i" }, "<Esc><Esc>", ":silent! close<CR>", { desc = "Close current window" })
vim.keymap.set("v", "v", "g_", { noremap = true, desc = "Visual to end of line (non-newline)" })
vim.keymap.set("n", "<leader>`", "<C-^>", { noremap = true, desc = "Swap with previous file" })
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload nvim config" })
vim.keymap.set("n", "<leader>fm", format_buffer, { desc = "Format current buffer" })
vim.keymap.set(
  "v",
  "<leader>r",
  '"hy:%s/<C-r>h//g<left><left>',
  { desc = "Replace all instances of highlighted words" }
)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected code down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected code up" })
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("n", "<A-k>", "<cmd>cprev<CR>", { desc = "Quick fix next" })
vim.keymap.set("n", "<A-j>", "<cmd>cnext<CR>", { desc = "Quick fix prev" })
vim.keymap.set("n", "<leader>s", 'q:isilent grep "test" | copen', { desc = "Search via grep" })
vim.keymap.set("n", "<leader>sw", grep_under_cursor, { desc = "Search current word via grep" })
vim.keymap.set("n", "<leader><leader>", ":find ", { desc = "Find file" })
vim.keymap.set("n", "<leader>fr", oldfiles_list, { desc = "Open old files" })
vim.keymap.set("n", "<leader>.", toggle_scratch_buffer, { desc = "Open scratch buffer" })
vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", '"', '""<left>')
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "{;", "{};<left><left>")
vim.keymap.set("i", "/*", "/**/<left><left>")

-- Lsp.
vim.diagnostic.config({
  signs = {
    active = true,
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
  virtual_text = true,
  underline = true,
  update_in_insert = false,
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

vim.lsp.enable({ "clangd", "lua_ls", "ts_ls" }) -- https://github.com/neovim/nvim-lspconfig

vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  end
end, { desc = "Show LSP client info" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    -- Navigation.
    vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gs", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

    -- Information.
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

    -- Code actions.
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

    -- Diagnostics.
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, opts)
  end,
})

-- Autocompletion.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
vim.cmd("set completeopt+=noselect")

-- Basic autocommands.
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Return to last edit position when opening files.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close quickfix after pressing <CR> on an item
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true })
  end,
})
