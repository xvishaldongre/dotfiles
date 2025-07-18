return {
	-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
