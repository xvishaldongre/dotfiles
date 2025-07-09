return {
	"vague2k/vague.nvim",
	enabled = true,
	priority = 1000,
	name = "vague",
	opts = {},
	config = function(_, opts)
		require("vague").setup(opts)
		vim.cmd.colorscheme("vague")
	end,
}
