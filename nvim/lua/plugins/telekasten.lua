return {
	"renerocksai/telekasten.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {
		home = vim.fn.expand("~/Documents/notes"),
	},
	keys = {
		-- Launch panel if nothing is typed after <leader>z
		{ mode = "n", "<leader>z", "<cmd>Telekasten panel<CR>" },

		-- Most used functions
		{ mode = "n", "<leader>zf", "<cmd>Telekasten find_notes<CR>" },
		{ mode = "n", "<leader>zg", "<cmd>Telekasten search_notes<CR>" },
		{ mode = "n", "<leader>zd", "<cmd>Telekasten goto_today<CR>" },
		{ mode = "n", "<leader>zz", "<cmd>Telekasten follow_link<CR>" },
		{ mode = "n", "<leader>zn", "<cmd>Telekasten new_note<CR>" },
		{ mode = "n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>" },
		{ mode = "n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>" },
		{ mode = "n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>" },

		-- Call insert link automatically when we start typing a link
		{ mode = "i", "[[", "<cmd>Telekasten insert_link<CR>" },
	},
}
