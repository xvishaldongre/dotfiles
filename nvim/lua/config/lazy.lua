-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	keys = { { "<leader>cl", "<cmd>Lazy<cr>", desc = "Lazy" } },
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	-- install = { colorscheme = { "tokyonight", "habamax" } },
	-- automatically check for plugin updates
	ui = {
		border = "rounded", -- options: "none", "single", "double", "rounded", etc.
	},
	performance = {
		cache = {
			enabled = true,
			-- disable_events = {},
		},
		rtp = {
			disabled_plugins = {
				"gzip", -- disable unless you open .gz files
				"zipPlugin", -- disable unless you need .zip browsing
				"tarPlugin", -- disable unless you open .tar archives
				"tohtml", -- disable unless you use :TOhtml export
				-- "tutor", -- disable if you’re past the beginner stage
				"editorconfig", -- optional: enable if you use editorconfig
				-- "man", -- optional: enable if you view man pages in `:Man`
				-- "matchit", -- useful: enables % across blocks/tags
				-- "matchparen", -- useful: shows cursor matching brackets
				"netrwPlugin", -- enable if you still use netrw for file browsing
				"rplugin", -- disables remote plugin loader (if you're not using plugins like fzf-rs)
				"shada", -- disable only if you don't want session/journal/history persistence
				"spellfile", -- disable if you don't use spell checking
				"osc52", -- leave enabled if you use clipboard copy over SSH
			},
		},
	},
	checker = { enabled = true },
})
