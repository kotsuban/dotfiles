-- Based on https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/evil_lualine.lua

local colors = {
  bg = "#11111B",
  fg = "#89b4fa",
  mauve = "#cba6f7",
  text = "#cdd6f4",
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
}

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local config = {
        options = {
          component_separators = "",
          section_separators = "",
          theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      -- Inserts a component in lualine_c at left section
      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        color = { fg = colors.fg, gui = "bold" },
      })

      ins_left({
        "diff",
        cond = conditions.buffer_not_empty,
      })

      ins_right({
        "diagnostics",
        cond = conditions.buffer_not_empty,
      })

      ins_right({
        function()
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
        color = { fg = colors.mauve, gui = "bold" },
        padding = { right = 0 },
      })

      ins_right({
        function()
          return "on"
        end,
        color = { fg = colors.text },
      })

      ins_right({
        "branch",
        icon = "",
        color = { gui = "bold" },
        padding = { left = 0, right = 1 },
      })

      return config
    end,
  },
}
