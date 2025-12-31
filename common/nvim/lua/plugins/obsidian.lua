-- helpers ---------------------------------------------------------
local function ensure_dir(path)
	path = vim.fn.expand(path)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, "p")
	end
end

-- ensure workspace + notes dirs -----------------------------------
ensure_dir("~/shared")
ensure_dir("~/shared/notes")
ensure_dir("~/shared/notes/daily")

-- optional template check -----------------------------------------
local daily_template_path = vim.fn.expand("~/shared/templates/daily.md")
local daily_template = vim.fn.filereadable(daily_template_path) == 1 and "daily.md" or nil

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"yousefhadder/markdown-plus.nvim",
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

		-- Workspaces
		workspaces = {
			{
				name = "notes",
				path = "~/shared/",
				strict = true,
				overrides = {
					notes_subdir = "notes",
				},
			},
			-- add more vaults here if needed...
		},

		-- Default subdirectory for notes
		-- notes_subdir = "notes",
		-- new_notes_location = "notes_subdir",
		daily_notes = {
			folder = "notes/daily", -- relative to your vault root
			date_format = "%Y-%m-%d", -- optional, how the date is formatted in filenames
			alias_format = nil, -- optional alias format
			default_tags = { "daily-notes" }, -- optional tags
			template = daily_template, -- ignored if not present
		},

		-- template
		templates = {
			folder = "notes/template",
			date_format = "%Y-%m-%d-%a",
			time_format = "%H:%M",
		},
		----------------------------------------------------------------
		-- Filename / ID generation: slug format (foo-bar.md)
		----------------------------------------------------------------
		-- 1. This tells the plugin: "Use the title I typed as the ID/Filename"
		note_id_func = function(title)
			if title ~= nil then
				-- If you type 'db.postgres.replication', the filename will be 'db.postgres.replication.md'
				-- We transform it to lowercase and replace spaces with hyphens, but keep dots.
				return title:gsub(" ", "-"):lower()
			end
			-- Fallback: if no title is provided, use a timestamp
			return tostring(os.time())
		end,

		-- 2. Logic to generate the "Title" from the filename
		note_frontmatter_func = function(note)
			-- Get the filename without the path/extension
			local name = note.id

			-- Extract string after the last dot (e.g., "fruit.awesome-apples" -> "awesome-apples")
			local last_part = name:match("([^.]+)$") or name

			local title = last_part
			-- Check if it's NOT already capitalized (like Custom-Capitalization)
			-- If it's all lowercase/hyphenated, transform it
			if last_part:match("^%l") then
				-- Replace hyphens with spaces and capitalize words
				title = last_part:gsub("-", " "):gsub("(%a)([%w]*)", function(first, rest)
					return first:upper() .. rest:lower()
				end)
			end

			local out = { title = title, aliases = note.aliases, tags = note.tags }

			-- Merge existing metadata if it exists
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end

			return out
		end,

		preferred_link_style = "markdown",

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
		ui = { enable = true },
	},
}
