-- lua/plugins/conform.lua
return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>cF",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "v" },
			desc = "Format Injected Langs",
		},
	},
	opts = {
		notify_on_error = true,
		format_on_save = function(bufnr)
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_fallback = true }
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { { "prettierd", "prettier" } },
			-- etc.
		},
	},

	-- init runs *before* lazy-loading, so which-key will see the <leader>uf mapping immediately
	init = function(_, opts)
		local Snacks = require("snacks")

		-- define a new toggle called "Auto Format-on-Save"
		Snacks.toggle
			.new({
				id = "format_on_save", -- internal flag name
				name = "Format-on-Save", -- label shown in which-key
				get = function() -- is it currently ON?
					return not vim.g.disable_autoformat
				end,
				set = function(state) -- turn it ON/OFF
					vim.g.disable_autoformat = not state
				end,
			})
			:map("<leader>uf")
	end,

	config = function(_, opts)
		require("conform").setup(opts)
	end,
}
