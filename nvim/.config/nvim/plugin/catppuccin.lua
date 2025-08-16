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
