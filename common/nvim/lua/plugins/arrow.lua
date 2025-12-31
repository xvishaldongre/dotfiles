return {
	"otavioschwanck/arrow.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "echasnovski/mini.icons" },
	},
	opts = {
		show_icons = true,
		leader_key = "gh",
		buffer_leader_key = "m",
	},
	keys = {
		{
			"<C-s>",
			function()
				require("arrow.persist").toggle()
			end,
			desc = "Arrow Persist Toggle",
		},
	},
}
