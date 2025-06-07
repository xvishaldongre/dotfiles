return {
	"rebelot/kanagawa.nvim",
	enabled = false,
	-- lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("kanagawa").setup({
			transparent = true,
			commentStyle = { italic = false },
			background = { -- map the value of 'background' option to a theme
				dark = "dragon", -- try "dragon" !
				light = "lotus",
			},
		})
		vim.cmd.colorscheme("kanagawa")
	end,
}
