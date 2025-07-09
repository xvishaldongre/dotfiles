return {
	enabled = false,
	event = "VimEnter",
	"romgrk/barbar.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		-- Add your configuration options here
	},
	keys = {
		-- Move to previous/next
		{ "<C-h>", "<Cmd>BufferPrevious<CR>", mode = "n" },
		{ "<C-l>", "<Cmd>BufferNext<CR>", mode = "n" },

		-- Re-order to previous/next
		{ "<A-<>", "<Cmd>BufferMovePrevious<CR>", mode = "n" },
		{ "<A->>", "<Cmd>BufferMoveNext<CR>", mode = "n" },

		-- Goto buffer in position...
		{ "<A-1>", "<Cmd>BufferGoto 1<CR>", mode = "n" },
		{ "<A-2>", "<Cmd>BufferGoto 2<CR>", mode = "n" },
		{ "<A-3>", "<Cmd>BufferGoto 3<CR>", mode = "n" },
		{ "<A-4>", "<Cmd>BufferGoto 4<CR>", mode = "n" },
		{ "<A-5>", "<Cmd>BufferGoto 5<CR>", mode = "n" },
		{ "<A-6>", "<Cmd>BufferGoto 6<CR>", mode = "n" },
		{ "<A-7>", "<Cmd>BufferGoto 7<CR>", mode = "n" },
		{ "<A-8>", "<Cmd>BufferGoto 8<CR>", mode = "n" },
		{ "<A-9>", "<Cmd>BufferGoto 9<CR>", mode = "n" },
		{ "<A-0>", "<Cmd>BufferLast<CR>", mode = "n" },

		-- Pin/unpin buffer
		{ "<C-p>", "<Cmd>BufferPin<CR>", mode = "n" },

		-- Close buffer
		{ "<C-x>", "<Cmd>BufferClose<CR>", mode = "n" },

		-- Magic buffer-picking mode
		{ "<C-s>", "<Cmd>BufferPick<CR>", mode = "n" },
		{ "<C-s-p>", "<Cmd>BufferPickDelete<CR>", mode = "n" },

		-- Sort automatically by...
		{ "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", mode = "n" },
		{ "<Space>bn", "<Cmd>BufferOrderByName<CR>", mode = "n" },
		{ "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", mode = "n" },
		{ "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", mode = "n" },
		{ "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", mode = "n" },
	},
}
