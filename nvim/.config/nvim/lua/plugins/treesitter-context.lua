return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      -- Remove ugly stupid underline in the context thing.
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { gui = nil })
    end,
    opts = function()
      return { mode = "topline" }
    end,
  },
}
