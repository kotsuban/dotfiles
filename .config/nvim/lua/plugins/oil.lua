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

return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    columns = {
      "icon",
      "size",
    },
    keymaps = {
      ["<CR>"] = "actions.select",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["<C-l>"] = "actions.refresh",
      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
    },
    use_default_keymaps = false,
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
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    { "_", "<cmd>Oil .<cr>", desc = "Open root directory" },
    { "+", "<cmd>Oil ~/Downloads/<cr>", desc = "Open downloads directory" },
  },
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
}
