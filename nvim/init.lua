require("config.lazy")
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-U>", "<C-U>zz")
vim.keymap.set("n", "<C-D>", "<C-D>zz")
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open Oil in a floating window" })
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.directory = vim.fn.expand("~/.nvim/swp//") -- note the double slashes for recursive use

local hardmode = true
if hardmode then
	-- Show an error message if a disabled key is pressed
	local msg = [[<cmd>echohl Error | echo "KEY DISABLED" | echohl None<CR>]]

	-- Disable arrow keys in insert mode with a styled message
	vim.api.nvim_set_keymap("i", "<Up>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Down>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Left>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Right>", "<C-o>" .. msg, { noremap = true, silent = false })
	-- vim.api.nvim_set_keymap("i", "<Del>", "<C-o>" .. msg, { noremap = true, silent = false })
	-- vim.api.nvim_set_keymap("i", "<BS>", "<C-o>" .. msg, { noremap = true, silent = false })

	-- Disable arrow keys in normal mode with a styled message
	vim.api.nvim_set_keymap("n", "<Up>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Down>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Left>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Right>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<BS>", msg, { noremap = true, silent = false })
end

-- Make CursorHold show a floating diagnostic
vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- Apply your “no virtual text by default” *after* any LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		vim.diagnostic.config({
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})
	end,
})

-- Define your toggle command
vim.api.nvim_create_user_command("ToggleVirtualText", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config(vim.tbl_extend("force", cfg, {
		virtual_text = not cfg.virtual_text,
	}))
end, {})

-- Add the descriptive mapping
vim.keymap.set("n", "<leader>tt", ":ToggleVirtualText<CR>", {
	noremap = true,
	silent = true,
	desc = "Toggle virtual text diagnostics",
})
