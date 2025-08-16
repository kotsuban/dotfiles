vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/nvim-treesitter/nvim-treesitter",
}, { load = true })

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "diff",
    "html",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
    "tsx",
  },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true, disable = { "ruby" } },
})
require("treesitter-context").setup({ mode = "topline" })

vim.api.nvim_set_hl(0, "TreesitterContextBottom", { gui = nil }) -- Fix treesitter-context ugly line.
