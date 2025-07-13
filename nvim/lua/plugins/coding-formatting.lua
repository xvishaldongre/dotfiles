return {
	"stevearc/conform.nvim",
	event = "VeryLazy",
	opts = {
		notify_on_error = true,
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { { "prettierd", "prettier" } },
			typescript = { { "prettierd", "prettier" } },
			javascriptreact = { { "prettierd", "prettier" } },
			typescriptreact = { { "prettierd", "prettier" } },
			json = { { "prettierd", "prettier" } },
			-- For YAML, you can use prettier or rely on yamlls if it supports formatting
			-- Prettier is often preferred for consistency across filetypes.
			yaml = { { "prettierd", "prettier" } },
			markdown = { { "prettierd", "prettier" } },
			html = { { "prettierd", "prettier" } },
			css = { { "prettierd", "prettier" } },
			scss = { { "prettierd", "prettier" } },
			sh = { "shfmt" },
			go = { "goimports", "gofumpt" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			require("conform").format({ async = true, lsp_fallback = true })
		end, { desc = "Format buffer with Conform" })
	end,
}
