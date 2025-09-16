return {
	"leath-dub/snipe.nvim",
	opts = {
		ui = {
			open_win_override = {
				title = "Buffers",
				border = "rounded", -- use "rounded" for rounded border
			},
		},
	},
	keys = {
		{
			"<leader>b",
			function()
				require("snipe").open_buffer_menu()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
}
