-- lua/plugins/obsidian.lua
local home = vim.fn.expand

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	event = "VeryLazy",
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"echasnovski/mini.pick",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		-- Note management
		{ mode = "n", "<leader>on", ":ObsidianNew<CR>" },
		-- {mode ="n", "<leader>ont", ":ObsidianNewFromTemplate<CR>"},
		{ mode = "n", "<leader>or", ":ObsidianRename<CR>" },

		-- Navigation
		-- {mode ="n", "<leader>oo", ":ObsidianOpen<CR>"},
		{ mode = "n", "<leader>oq", ":ObsidianQuickSwitch<CR>" },
		{ mode = "n", "<leader>of", ":ObsidianFollowLink<CR>" },
		{ mode = "n", "<leader>oj", ":ObsidianTOC<CR>" },

		-- Daily notes
		{ mode = "n", "<leader>ot", ":ObsidianToday<CR>" },
		{ mode = "n", "<leader>oy", ":ObsidianYesterday<CR>" },
		{ mode = "n", "<leader>oT", ":ObsidianTomorrow<CR>" },
		{ mode = "n", "<leader>od", ":ObsidianDailies<CR>" },

		-- Linking
		{ mode = "n", "<leader>ol", ":ObsidianLink<CR>" },
		{ mode = "n", "<leader>oL", ":ObsidianLinkNew<CR>" },
		{ mode = "n", "<leader>ok", ":ObsidianLinks<CR>" },

		-- Search
		{ mode = "n", "<leader>os", ":ObsidianSearch<CR>" },
		{ mode = "n", "<leader>ob", ":ObsidianBacklinks<CR>" },
		{ mode = "n", "<leader>oa", ":ObsidianTags<CR>" },

		-- Templates and checkboxes
		{ mode = "n", "<leader>op", ":ObsidianTemplate<CR>" },
		{ mode = "n", "<leader>ox", ":ObsidianToggleCheckbox<CR>" },

		-- Workspace
		{ mode = "n", "<leader>ow", ":ObsidianWorkspace<CR>" },
	},
	opts = {
		-- Vault root
		dir = home("~/Documents/notes"),

		-- Workspaces
		workspaces = {
			{
				name = "notes",
				path = home("~/Documents/notes"),
				overrides = {
					notes_subdir = "notes",
				},
			},
			-- add more vaults here if needed...
		},

		-- Default subdirectory for notes
		notes_subdir = "notes",
		new_notes_location = "notes_subdir",

		----------------------------------------------------------------
		-- Filename / ID generation: slug format (foo-bar.md)
		----------------------------------------------------------------
		note_id_func = function(title)
			if title and #title > 0 then
				return title:gsub("%s+", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			else
				-- fallback to timestamp if no title given
				return tostring(os.time())
			end
		end,

		note_path_func = function(spec)
			-- spec.id is the slug created above
			local path = spec.dir / spec.id
			return path:with_suffix(".md")
		end,

		----------------------------------------------------------------
		-- Link formatting: use_alias_only
		----------------------------------------------------------------
		-- Wiki links: [[Alias Only]]
		wiki_link_func = function(opts)
			return string.format("[[%s]]", opts.alias)
		end,

		-- Markdown links: [Alias Only]
		markdown_link_func = function(opts)
			return string.format("[%s]", opts.alias)
		end,

		preferred_link_style = "markdown", -- still defaults to markdown

		----------------------------------------------------------------
		-- Completion and picker settings
		----------------------------------------------------------------
		completion = {
			blink = true,
			min_chars = 2,
		},

		picker = {
			name = "snacks.pick",
			note_mappings = {
				new = "<C-x>",
				insert_link = "<C-l>",
			},
			tag_mappings = {
				tag_note = "<C-x>",
				insert_tag = "<C-l>",
			},
		},
		ui = { enable = false },
	},
}
