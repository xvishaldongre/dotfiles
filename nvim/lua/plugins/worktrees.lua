return {
	"Juksuu/worktrees.nvim",
	event = "VeryLazy",
	config = function()
		require("worktrees").setup()
	end,
}
