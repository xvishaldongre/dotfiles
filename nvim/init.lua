vim.loader.enable()
-- Load Lazy plugin manager
require("config.lazy")

-- Section: UI Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.opt.termguicolors = true
vim.o.scrolloff = 10
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.laststatus = 3

-- Section: Editor Behavior
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.directory = vim.fn.expand("~/.nvim/swp//") -- Swap directory

-- Section: Clipboard
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- stylua: ignore start
-- Section: Keymaps
local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end
map("n","<leader>cl","<cmd>Lazy<CR>", "Lazy")
-- Stole from ThePrimeagen
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")
map("n", "n", "nzzzv", "Next search result centered")
map("n", "N", "Nzzzv", "Previous search result centered")
map({ "n", "v" }, "<leader>d", [["_d]], "Delete without affecting clipboard")
map({ "n", "v" }, "<leader>x", [["_x]], "Delete char without affecting clipboard")

-- General
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("i", "jj", "<Esc>", "Exit insert mode")

-- Window Resize
map("n", "<M-,>", "<C-w>5<", "Resize left")
map("n", "<M-.>", "<C-w>5>", "Resize right")
map("n", "<M-t>", "<C-w>+", "Resize up")
map("n", "<M-s>", "<C-w>-", "Resize down")

-- Scrolling
map("n", "<C-u>", "<C-u>zz", "Scroll up centered")
map("n", "<C-d>", "<C-d>zz", "Scroll down centered")

-- Quit
map("n", "<leader>qq", ":qa<CR>", "Quit all")
map("n", "<leader>q!", ":qa!<CR>", "Force quit all")

-- Buffers
map("n", "<C-h>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<C-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<C-j>", "<C-^>", "Alternate buffer")
map("n", "<C-k>", Snacks.picker.buffers, "Buffer picker")
map("n", "<C-;>", "<cmd>bdelete<CR>", "Delete buffer")

-- stylua: ignore end
-- Section: Yank Highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Section: Hardmode (Disable Arrow Keys)
local hardmode = true
if hardmode then
	local msg = [[<cmd>echohl Error | echo "KEY DISABLED" | echohl None<CR>]]

	-- Insert mode
	vim.api.nvim_set_keymap("i", "<Up>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Down>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Left>", "<C-o>" .. msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("i", "<Right>", "<C-o>" .. msg, { noremap = true, silent = false })

	-- Normal mode
	vim.api.nvim_set_keymap("n", "<Up>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Down>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Left>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<Right>", msg, { noremap = true, silent = false })
	vim.api.nvim_set_keymap("n", "<BS>", msg, { noremap = true, silent = false })
end

-- Section: Floating Diagnostics on CursorHold
vim.api.nvim_create_autocmd({ "CursorHold" }, {
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- Section: LSP Diagnostic Config
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

-- Section: Toggle Diagnostic Virtual Text
vim.api.nvim_create_user_command("ToggleVirtualText", function()
	local cfg = vim.diagnostic.config()
	vim.diagnostic.config(vim.tbl_extend("force", cfg, {
		virtual_text = not cfg.virtual_text,
	}))
end, {})

vim.api.nvim_create_user_command("ListWins", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local cfg = vim.api.nvim_win_get_config(win)
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		print(string.format("win=%d buf=%d ft=%s relative=%s", win, buf, ft, tostring(cfg.relative)))
	end
end, { desc = "List all windows with config info" })
