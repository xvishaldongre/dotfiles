return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy",
	cond = vim.g.neovide == nil,
	opts = {
		hide_target_hack = true,
		cursor_color = "none",
		stiffness = 0.8, -- 0.6      [0, 1]
		trailing_stiffness = 0.5, -- 0.4      [0, 1]
		stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
		trailing_stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
		distance_stop_animating = 0.5, -- 0.1      > 0
		time_interval = 7, -- milliseconds
	},
	specs = {
		-- disable mini.animate cursor
		{
			"echasnovski/mini.animate",
			optional = true,
			opts = {
				cursor = { enable = false },
			},
		},
	},
}
