vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })

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
		local path = vim.loop.cwd() .. "/.git"
		local git_dir = vim.loop.fs_stat(path)
		local is_git_repo = git_dir and git_dir.type == "directory"

		return is_git_repo and "on", ""
	end,
	color = { fg = colors.text },
})

ins_right({
	"branch",
	icon = "",
	color = { gui = "bold" },
	padding = { left = 0, right = 1 },
})

require("lualine").setup(config)
