return {
  "MagicDuck/grug-far.nvim",
  keys = {
    {
      "<leader>se",
      function()
        local grug = require("grug-far")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = vim.fn.expand("%"),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace within current file",
    },
  },
}
