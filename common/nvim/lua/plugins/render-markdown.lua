return {
	"MeanderingProgrammer/render-markdown.nvim",
	enabled = true,
	ft = { "markdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite

	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standanlone mini plugins
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
	config = function()
		require("render-markdown").setup({
			-- your configuration here
			-- Globally enable rendering
			enabled = true,
			render_modes = { "n", "c", "t" },

			----------------------------------------------------------------
			-- Headings
			----------------------------------------------------------------
			heading = {
				enabled = false, -- turn on heading rendering
				sign = false, -- disable gutter sign
				position = "overlay", -- or "inline"
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				signs = { "󰫎 " },
				width = "full", -- "block" | "full"
				backgrounds = {
					"RenderMarkdownH1Bg",
					"RenderMarkdownH2Bg",
					"RenderMarkdownH3Bg",
					"RenderMarkdownH4Bg",
					"RenderMarkdownH5Bg",
					"RenderMarkdownH6Bg",
				},
				foregrounds = {
					"RenderMarkdownH1",
					"RenderMarkdownH2",
					"RenderMarkdownH3",
					"RenderMarkdownH4",
					"RenderMarkdownH5",
					"RenderMarkdownH6",
				},
			},

			----------------------------------------------------------------
			-- Code Blocks
			----------------------------------------------------------------
			code_blocks = {
				enabled = false,
				background = true,
				border = true,
				padding = 1,
				width = "full", -- "block" | "full"
				language_icon = true,
				language_name = true,
				position = "left", -- margin side
				language_pad = 0, -- padding around icon/name
				left_margin = 0, -- extra margin before block
			},

			----------------------------------------------------------------
			-- Inline Code
			----------------------------------------------------------------
			inline_code = {
				enabled = false,
				background = true,
			},

			----------------------------------------------------------------
			-- Horizontal Breaks
			----------------------------------------------------------------
			horizontal_breaks = {
				enabled = true,
				icon = "─",
				color = nil, -- use default highlight
				width = "full", -- "block" | "full"
			},

			----------------------------------------------------------------
			-- List Bullets
			----------------------------------------------------------------
			bullet = {
				enabled = false,
				icon = "•",
				color = nil,
				padding = 1,
			},

			----------------------------------------------------------------
			-- Checkboxes
			----------------------------------------------------------------
			checkboxes = {
				enabled = false,
				icons = { "☐", "☑", "✔" },
				color = nil,
				-- you can also define named states:
				-- states = { todo = "☐", done = "✔", inprogress = "☑" },
			},

			----------------------------------------------------------------
			-- Block Quotes
			----------------------------------------------------------------
			block_quotes = {
				enabled = false,
				icon = "❝",
				color = nil,
				line_breaks = 1,
			},

			----------------------------------------------------------------
			-- Callouts
			----------------------------------------------------------------
			callouts = {
				enabled = true,
				icon = "⚠",
				color = nil,
				-- define custom callout types if you like:
				-- types = {
				--   info   = { icon = "ℹ️", color = "Blue" },
				--   warn   = { icon = "⚠", color = "Orange" },
				--   note   = { icon = "📝", color = "Green" },
				-- },
			},

			----------------------------------------------------------------
			-- Tables
			----------------------------------------------------------------
			tables = {
				enabled = true,
				border = true,
				color = nil,
				alignment_indicator = true,
				auto_align_cells = true,
			},

			----------------------------------------------------------------
			-- Links
			----------------------------------------------------------------
			link = { -- Turn on / off inline link icon rendering.
				enabled = true,
				-- Additional modes to render links.
				render_modes = false,
				-- How to handle footnote links, start with a '^'.
				footnote = {
					-- Turn on / off footnote rendering.
					enabled = true,
					-- Replace value with superscript equivalent.
					superscript = true,
					-- Added before link content.
					prefix = "",
					-- Added after link content.
					suffix = "",
				},
				-- Inlined with 'image' elements.
				image = "󰥶 ",
				-- Inlined with 'email_autolink' elements.
				email = "󰀓 ",
				-- Fallback icon for 'inline_link' and 'uri_autolink' elements.
				hyperlink = "󰌹 ",
				-- Applies to the inlined icon as a fallback.
				highlight = "RenderMarkdownLink",
				-- Applies to WikiLink elements.
				wiki = {
					icon = "󱗖 ",
					body = function()
						return nil
					end,
					highlight = "RenderMarkdownWikiLink",
				},
				-- Define custom destination patterns so icons can quickly inform you of what a link
				-- contains. Applies to 'inline_link', 'uri_autolink', and wikilink nodes. When multiple
				-- patterns match a link the one with the longer pattern is used.
				-- The key is for healthcheck and to allow users to change its values, value type below.
				-- | pattern   | matched against the destination text                            |
				-- | icon      | gets inlined before the link text                               |
				-- | kind      | optional determines how pattern is checked                      |
				-- |           | pattern | @see :h lua-patterns, is the default if not set       |
				-- |           | suffix  | @see :h vim.endswith()                                |
				-- | priority  | optional used when multiple match, uses pattern length if empty |
				-- | highlight | optional highlight for 'icon', uses fallback highlight if empty |
				custom = {
					web = { pattern = "^http", icon = "󰖟 " },
					discord = { pattern = "discord%.com", icon = "󰙯 " },
					github = { pattern = "github%.com", icon = "󰊤 " },
					gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
					google = { pattern = "google%.com", icon = "󰊭 " },
					neovim = { pattern = "neovim%.io", icon = " " },
					reddit = { pattern = "reddit%.com", icon = "󰑍 " },
					stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
					wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
					youtube = { pattern = "youtube%.com", icon = "󰗃 " },
				},
			},

			----------------------------------------------------------------
			-- LaTeX Blocks
			----------------------------------------------------------------
			latex = {
				enabled = true,
				-- converter = "latex2text",
				-- position  = "above",
				-- top_pad   = 0,
			},

			----------------------------------------------------------------
			-- Org Indent Mode
			----------------------------------------------------------------
			org_indent_mode = {
				enabled = true,
				padding_per_level = 1,
			},
		})
	end,
}
