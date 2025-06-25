return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      -- Remove ugly stupid underline in the context thing.
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { gui = nil })

      -- https://github.com/nvim-treesitter/nvim-treesitter-context/issues/620
      require("treesitter-context").setup({})
    end,
    opts = function()
      return { mode = "topline" }
    end,
  },
}
