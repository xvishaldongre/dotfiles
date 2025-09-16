return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
		--  - ci'  - [C]hange [I]nside [']quote
		-- require('mini.ai').setup { n_lines = 500 }

		--
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		-- require('mini.surround').setup()

		-- require('mini.files').setup()
		-- require("mini.comment")
		-- require("mini.cursorword").setup()
		-- require("mini.git").setup()
		require("mini.diff").setup({
			-- Options for how hunks are visualized
			view = {
				-- Visualization style. Possible values are 'sign' and 'number'.
				-- Default: 'number' if line numbers are enabled, 'sign' otherwise.
				style = vim.go.number and "number" or "sign",

				-- Signs used for hunks with 'sign' view
				signs = { add = "▎", change = "▎", delete = "▎" },
				-- signs = { add = "+", change = "~", delete = "_" },

				-- Priority of used visualization extmarks
				priority = 199,
			},

			-- Source(s) for how reference text is computed/updated/etc
			-- Uses content from Git index by default
			source = nil,

			-- Delays (in ms) defining asynchronous processes
			delay = {
				-- How much to wait before update following every text change
				text_change = 100,
			},

			-- Module mappings. Use `''` (empty string) to disable one.
			mappings = {
				-- Apply hunks inside a visual/operator region
				apply = "gh",

				-- Reset hunks inside a visual/operator region
				reset = "gH",

				-- Hunk range textobject to be used inside operator
				-- Works also in Visual mode if mapping differs from apply and reset
				textobject = "gh",

				-- Go to hunk range in corresponding direction
				goto_first = "[H",
				goto_prev = "[h",
				goto_next = "]h",
				goto_last = "]H",
			},

			-- Various options
			options = {
				-- Diff algorithm. See `:h vim.diff()`.
				algorithm = "histogram",

				-- Whether to use "indent heuristic". See `:h vim.diff()`.
				indent_heuristic = true,

				-- The amount of second-stage diff to align lines
				linematch = 60,

				-- Whether to wrap around edges during hunk navigation
				wrap_goto = false,
			},
		})

		require("mini.pairs").setup()

		-- Simple and easy statusline.
		--  You could remove this setup call if you don't like it,
		--  and try some other statusline plugin
		local statusline = require("mini.statusline")
		-- set use_icons to true if you have a Nerd Font
		statusline.setup({ use_icons = vim.g.have_nerd_font })

		-- You can configure sections in the statusline by overriding their
		-- default behavior. For example, here we set the section for
		-- cursor location to LINE:COLUMN
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end

		-- ... and there is more!
		--  Check out: https://github.com/echasnovski/mini.nvim
	end,
	keys = {
		{
			"<leader>gd",
			function()
				-- pass 0 to act on the current buffer
				require("mini.diff").toggle_overlay(0)
			end,
			desc = "Toggle mini.diff inline overlay",
		},
	},
}
