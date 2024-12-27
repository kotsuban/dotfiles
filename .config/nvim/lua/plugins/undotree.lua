return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = { { "<leader>gu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undo Tree" } },
  config = function()
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_DiffAutoOpen = 0
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_WindowLayout = 3
  end,
}
