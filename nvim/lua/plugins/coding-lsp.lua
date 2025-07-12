-- init-lsp.lua
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = { ui = { border = "rounded" } },
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			-- "b0o/schemastore.nvim",
		},
		config = function()
			-- Shared on_attach
			local on_attach = function(client, bufnr)
				if client.server_capabilities.semanticTokensProvider then
					vim.treesitter.stop(bufnr)
				end

				local map = function(keys, func, desc, mode)
					vim.keymap.set(mode or "n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end

				map("grn", vim.lsp.buf.rename, "[R]ename")
				map("gra", function()
					if Snacks and Snacks.picker and Snacks.picker.lsp_code_actions then
						Snacks.picker.lsp_code_actions()
					else
						vim.lsp.buf.code_action()
					end
				end, "[C]ode [A]ction", { "n", "v" })
				map("K", vim.lsp.buf.hover, "Hover Doc")
				map("<leader>ls", vim.lsp.buf.signature_help, "Signature Help")
				map("<leader>lf", function()
					vim.lsp.buf.format({ async = true, bufnr = bufnr })
				end, "[F]ormat Document")

				if client.supports_method then
					local cap = vim.lsp.protocol.Methods.textDocument_documentHighlight
					if client.supports_method(client, cap, bufnr) then
						local grp = vim.api.nvim_create_augroup("lsp-hl", { clear = false })
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
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(ev)
					on_attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
				end,
			})

			-- Diagnostics config
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
						return string.format(
							"%s %s",
							icons[vim.diagnostic.severity[d.severity]:upper()] or "",
							d.message
						)
					end,
				},
				update_in_insert = false,
			})
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
			vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
			vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

			-- Load mason-lspconfig and mason-tool-installer
			local capabilities = require("blink.cmp").get_lsp_capabilities()
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
				clangd = {},
				gopls = {},
				html = {},
				cssls = {},
				jsonls = {
					settings = { json = { validate = { enable = true } } },
					-- on_new_config = function(cfg)
					-- 	cfg.settings.json = cfg.settings.json or {}
					-- 	cfg.settings.json.schemas = require("schemastore").json.schemas()
					-- end,
				},
				yamlls = {
					settings = {
						yaml = {
							validate = true,
							format = { enable = true },
							-- schemaStore = { enable = false, url = "" },
						},
					},
					-- on_new_config = function(cfg)
					-- 	cfg.settings.yaml = cfg.settings.yaml or {}
					-- 	cfg.settings.yaml.schemas = require("schemastore").yaml.schemas()
					-- end,
				},
				bashls = {},
				dockerls = {},
				marksman = {},
				basedpyright = {},
			}
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				handlers = {
					function(server)
						local opts = servers[server] or {}
						opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
						opts.on_attach = on_attach
						require("lspconfig")[server].setup(opts)
					end,
				},
			})
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"prettier",
					"shfmt",
					"shellcheck",
					"yaml-language-server",
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
}
