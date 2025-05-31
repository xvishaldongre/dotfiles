return {
	enabled = true,
	"romgrk/barbar.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		-- Add your configuration options here
	},
}
