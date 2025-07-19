-- lua/plugins/obsidian.lua
local expand = vim.fn.expand

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		-- Note Management
		{ mode = "n", "<leader>on", ":ObsidianNew<CR>", desc = "New note" },

		-- Navigation
		{ mode = "n", "<leader>oq", ":ObsidianQuickSwitch<CR>", desc = "Quick switch" },
		{ mode = "n", "<leader>of", ":ObsidianFollowLink<CR>", desc = "Follow link" },
		{ mode = "n", "<leader>oj", ":ObsidianTOC<CR>", desc = "Table of contents" },

		-- Daily Notes
		{ mode = "n", "<leader>ot", ":ObsidianToday<CR>", desc = "Open today’s note" },
		{ mode = "n", "<leader>oy", ":ObsidianYesterday<CR>", desc = "Open yesterday’s note" },
		{ mode = "n", "<leader>oT", ":ObsidianTomorrow<CR>", desc = "Open tomorrow’s note" },
		{ mode = "n", "<leader>od", ":ObsidianDailies<CR>", desc = "Browse dailies" },

		-- Linking
		{ mode = "n", "<leader>ol", ":ObsidianLink<CR>", desc = "Insert link" },
		{ mode = "n", "<leader>oL", ":ObsidianLinkNew<CR>", desc = "Insert new link" },
		{ mode = "n", "<leader>ok", ":ObsidianLinks<CR>", desc = "List backlinks" },

		-- Search & Tags
		{ mode = "n", "<leader>os", ":ObsidianSearch<CR>", desc = "Search vault" },
		{ mode = "n", "<leader>oa", ":ObsidianTags<CR>", desc = "Show tags" },

		-- Templates & Checkboxes
		{ mode = "n", "<leader>op", ":ObsidianTemplate<CR>", desc = "Insert template" },
		{ mode = "n", "<leader>ox", ":ObsidianToggleCheckbox<CR>", desc = "Toggle checkbox" },
	},
	opts = {
		-- Vault root
		-- dir = expand("~/Documents/notes"),

		-- Workspaces
		workspaces = {
			{
				name = "notes",
				path = "~/Documents/notes",
				strict = true,
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
			nvim_cmp = false,
			blink = true,
			min_chars = 1,
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
