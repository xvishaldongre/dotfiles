return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Autocompletion Engine (blink.cmp)
	{
		"saghen/blink.cmp",
		event = "VeryLazy",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
				opts = {},
			},
		},
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = true, auto_show_delay_ms = 250 } },
			sources = {
				default = { "lsp", "snippets", "path", "buffer", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
			cmdline = {
				keymap = { preset = "inherit" },
				completion = { menu = { auto_show = true } },
			},
		},
	},

	-- Main LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			-- snacks.nvim is now a top-level plugin, no longer a direct dep here
		},
		config = function()
			local on_attach = function(client, bufnr)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end

				-- Keybindings handled by on_attach (buffer-local or specific actions)
				map("grn", vim.lsp.buf.rename, "[R]e[n]ame") -- Standard rename

				-- Use Snacks picker for Code Actions
				map("gra", function()
					if Snacks and Snacks.picker and Snacks.picker.lsp_code_actions then
						Snacks.picker.lsp_code_actions()
					else
						vim.lsp.buf.code_action() -- Fallback if Snacks or its lsp_code_actions is not available
					end
				end, "[C]ode [A]ction", { "n", "v" })

				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<leader>ls", vim.lsp.buf.signature_help, "Signature Help")

				-- LSP navigation (gd, gr, gI, gy, <leader>ss, <leader>sS)
				-- is now handled by your global snacks.nvim keybindings.
				-- No need to redefine them here as buffer-local.

				local function client_supports_method(lsp_client, method, lsp_bufnr)
					if vim.fn.has("nvim-0.11") == 1 then
						return lsp_client:supports_method(method, { bufnr = lsp_bufnr })
					else
						return lsp_client.supports_method(method, { bufnr = lsp_bufnr })
					end
				end

				if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = bufnr,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = bufnr,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							if event2.buf == bufnr then
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end
						end,
					})
				end

				if client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
					end, "[T]oggle Inlay [H]ints")
				end

				if client.supports_method("textDocument/formatting") then
					map("<leader>lf", function()
						vim.lsp.buf.format({ async = true, bufnr = bufnr })
					end, "[F]ormat Document (LSP)")
				end
			end

			vim.api.nvim_create_augroup("kickstart-lsp-attach-config", { clear = true })
			vim.api.nvim_create_autocmd("LspAttach", {
				group = "kickstart-lsp-attach-config",
				callback = function(event)
					on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many", focusable = false },
				underline = { severity = { min = vim.diagnostic.severity.ERROR } },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 4,
					prefix = "●",
					format = function(diagnostic)
						local icons = { ERROR = "󰅚", WARN = "", INFO = "", HINT = "󰌶" }
						local icon = icons[vim.diagnostic.severity[diagnostic.severity]:upper()] or ""
						return string.format("%s %s", icon, diagnostic.message)
					end,
				},
				update_in_insert = false,
			})

			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
			vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
			vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

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
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					settings = {
						yaml = {
							schemaStore = {
								enable = false,
								url = "",
							},
							schemas = require("schemastore").yaml.schemas(), -- For Kubernetes etc.
							validate = true,
							completion = true,
							hover = true,
						},
					},
				},
				bashls = {},
				dockerls = {},
				marksman = {},
				basedpyright = {},
			}

			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				handlers = {
					function(server_name)
						local server_opts = servers[server_name] or {}
						server_opts.capabilities =
							vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
						server_opts.on_attach = on_attach
						require("lspconfig")[server_name].setup(server_opts)
					end,
				},
			})

			local ensure_installed_tools = {
				"stylua",
				"prettier",
				"shfmt",
				"shellcheck",
				"yaml-language-server",
			}
			require("mason-tool-installer").setup({
				ensure_installed = ensure_installed_tools,
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
	-- Formatting (conform.nvim)
	{
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
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				sh = { "shfmt" },
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "Format buffer with Conform" })
		end,
	},

	-- Schema integration for JSON/YAML
	{
		"b0o/schemastore.nvim",
		lazy = true, -- Load when schemastore.nvim is required by a server config
		-- No specific config needed here usually, it's used by lspconfig settings
	},

	-- Example: Add mini.nvim if you don't have it elsewhere
	-- This is a minimal setup for mini.actions. Adjust as per your full mini.nvim config.
	-- {
	--   'echasnovski/mini.nvim',
	--   version = false, -- Or specify a version
	--   config = function()
	--     -- Only setup modules you need. Here, just mini.actions for LSP.
	--     require('mini.actions').setup()
	--     -- If you use other mini modules, configure them here or in their respective plugin specs.
	--   end,
	-- },
}
