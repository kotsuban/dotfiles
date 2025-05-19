-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function jump_to_main_function()
  local filename = vim.fn.expand("%:t:r")
  local filetype = vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(filetype)

  if lang == nil then
    vim.notify("Treesitter language not found for filetype ." .. filetype, vim.log.levels.WARN)
    return
  end

  local parser = vim.treesitter.get_parser(0, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  local success, query = pcall(
    vim.treesitter.query.parse,
    lang,
    [[
        (function_declaration
            name: (identifier) @func_name)
    ]]
  )

  if not success then
    vim.notify("Main function not found: " .. filename, vim.log.levels.WARN)
    return
  end

  for _, node in query:iter_captures(root, 0, 0, -1) do
    local name = vim.treesitter.get_node_text(node, 0)
    if name == filename then
      local row, col = node:start()
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
      return
    end
  end

  vim.notify("Main function not found: " .. filename, vim.log.levels.WARN)
end

-- move selected part of code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- move last copied value into void registry afrer pasting something
vim.keymap.set("x", "<leader>P", '"_dP')

-- move copied value into void registry after deleting something
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')
vim.keymap.set("n", "]x", jump_to_main_function, { desc = "Jump to main function" })
