-- Define servers at the top-level
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				diagnostics = { globals = { "vim" } },
				workspace = { library = vim.api.nvim_get_runtime_file("", true) },
				telemetry = { enable = false },
			},
		},
	},
	jsonls = { settings = { json = { validate = { enable = true } } } },
	yamlls = { settings = { yaml = { validate = true, format = { enable = true } } } },
	gopls = {},
	bashls = {},
	dockerls = {},
	html = {},
	cssls = {},
	-- marksman = {},
	clangd = {},
	basedpyright = {},
}

-- Plugin spec
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Mason itself only on the :Mason command
		{
			"williamboman/mason.nvim",
			cmd = "Mason",
			keys = {
				{ "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
			},
			opts = {
				ui = { border = "rounded" },
			},
		},

		-- these two kick in *after* Mason is loaded
		{
			"williamboman/mason-lspconfig.nvim",
			after = "mason.nvim",
			config = true, -- auto-setup servers if you like
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			after = "mason.nvim",
			opts = {
				-- list your tools here, e.g. "lua-language-server", "pyright", etc.
			},
		},

		-- Fidget shows up as soon as an LSP attaches
		{
			"j-hui/fidget.nvim",
			event = "LspAttach",
			opts = {},
		},
	},
	config = function()
		local lspconfig = require("lspconfig")
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		local function on_attach(client, bufnr)
			if client.server_capabilities.semanticTokensProvider then
				client.server_capabilities.semanticTokensProvider = nil
			end

			if client.server_capabilities.documentHighlightProvider then
				local grp = vim.api.nvim_create_augroup("lsp-hl", { clear = true })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = bufnr,
					group = grp,
					callback = vim.lsp.buf.document_highlight,
				})
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = bufnr,
					group = grp,
					callback = vim.lsp.buf.clear_references,
				})
			end
		end

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many", focusable = false },
			underline = { severity = { min = vim.diagnostic.severity.ERROR } },
			virtual_text = {
				source = "if_many",
				spacing = 4,
				prefix = "●",
				format = function(d)
					local icons = { ERROR = "󰅚", WARN = "", INFO = "", HINT = "󰌶" }
					return string.format("%s %s", icons[vim.diagnostic.severity[d.severity]:upper()] or "", d.message)
				end,
			},
			update_in_insert = false,
		})

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
			handlers = {
				function(server_name)
					local opts = servers[server_name] or {}
					opts.on_attach = on_attach
					opts.capabilities = capabilities
					lspconfig[server_name].setup(opts)
				end,
			},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettier",
				"shellcheck",
				"shfmt",
				"stylua",
				"terraform-ls",
				"yaml-language-server",
			},
			auto_update = false,
			run_on_start = true,
		})

		require("fidget").setup({})
	end,
}
