vim.pack.add({ "https://github.com/catppuccin/nvim" }, { load = true })
require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  color_overrides = {
    mocha = {
      base = "#11111b",
      mantle = "#11111b",
      crust = "#11111b",
    },
  },
  integrations = {
    gitsigns = true,
    treesitter = true,
  },
})
vim.cmd.colorscheme("catppuccin")

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

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-treesitter/nvim-treesitter",
}, { load = true })
require("nvim-treesitter.configs").setup({
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true, disable = { "ruby" } },
})
require("treesitter-context").setup({ mode = "topline" })
vim.api.nvim_set_hl(0, "TreesitterContextBottom", { gui = nil }) -- Fix treesitter-context ugly line.

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
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
