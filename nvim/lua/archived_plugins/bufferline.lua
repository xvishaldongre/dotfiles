return {
	enabled = false,
	"akinsho/bufferline.nvim",
	event = "VimEnter",

	keys = {
		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
		{ "<C-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "<C-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
		{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },

		-- Barbar-like keymaps tweaked for bufferline
		{ "<A-<>", "<Cmd>BufferLineMovePrev<CR>", desc = "Move buffer prev" },
		{ "<A->>", "<Cmd>BufferLineMoveNext<CR>", desc = "Move buffer next" },

		{ "<A-1>", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "Goto buffer 1" },
		{ "<A-2>", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "Goto buffer 2" },
		{ "<A-3>", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "Goto buffer 3" },
		{ "<A-4>", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "Goto buffer 4" },
		{ "<A-5>", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "Goto buffer 5" },
		{ "<A-6>", "<Cmd>BufferLineGoToBuffer 6<CR>", desc = "Goto buffer 6" },
		{ "<A-7>", "<Cmd>BufferLineGoToBuffer 7<CR>", desc = "Goto buffer 7" },
		{ "<A-8>", "<Cmd>BufferLineGoToBuffer 8<CR>", desc = "Goto buffer 8" },
		{ "<A-9>", "<Cmd>BufferLineGoToBuffer 9<CR>", desc = "Goto buffer 9" },
		{ "<A-0>", "<Cmd>BufferLineGoToBuffer -1<CR>", desc = "Goto last buffer" },

		{ "<C-p>", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
		{ "<C-x>", "<Cmd>bd<CR>", desc = "Close buffer" },

		{ "<C-s>", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
		{ "<C-S>", "<Cmd>BufferLinePickClose<CR>", desc = "Pick buffer to close" },

		{ "<Space>bb", "<Cmd>BufferLineSortByBufferNumber<CR>", desc = "Sort by buffer number" },
		{ "<Space>bn", "<Cmd>BufferLineSortByName<CR>", desc = "Sort by name" },
		{ "<Space>bd", "<Cmd>BufferLineSortByDirectory<CR>", desc = "Sort by directory" },
		{ "<Space>bl", "<Cmd>BufferLineSortByLanguage<CR>", desc = "Sort by language" },
		{ "<Space>bw", "<Cmd>BufferLineSortByWindowNumber<CR>", desc = "Sort by window number" },
	},

	opts = {
		highlights = {
			indicator_selected = {
				underline = true,
				guifg = "#ff9e64", -- example underline color, adjust as you like
			},
		},
	},

	config = function(_, opts)
		require("nvim.lua.archived_plugins.bufferline").setup(opts)

		-- Fix bufferline when restoring a session
		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
	end,
}
