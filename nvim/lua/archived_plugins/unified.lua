return {
	"axkirillov/unified.nvim",
	event = "VeryLazy",
	opts = {
		signs = {
			add = "│",
			delete = "│",
			change = "│",
		},
		highlights = {
			add = "DiffAdd",
			delete = "DiffDelete",
			change = "DiffChange",
		},
		line_symbols = {
			add = "",
			delete = "",
			change = "",
		},
		auto_refresh = true,
	},
	keys = {
		{
			"<leader>gu",
			function()
				local diff = require("unified.diff")
				local buf = vim.api.nvim_get_current_buf()

				if diff.is_diff_displayed(buf) then
					-- clear all extmarks + signs and close tree
					vim.cmd("Unified reset")
				else
					-- diff current buffer against HEAD
					diff.show_current()
				end
			end,
			desc = "Toggle unified.nvim inline diff for current buffer",
		},
	},
}
