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
local function template_if_exists(name)
	local path = vim.fn.expand("~/shared/notes/template/" .. name)
	return vim.fn.filereadable(path) == 1 and name or nil
end

local daily_template = template_if_exists("daily.md")
local new_note_template = template_if_exists("new-note.md")

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
		-- habit tracker
		{
			mode = "n",
			"<leader>oh",
			function()
				local daily_dir = vim.fn.expand("~/shared/notes/daily")
				local files = vim.fn.globpath(daily_dir, "*.md", false, true)
				table.sort(files)
				-- take last 30
				local last_30 = {}
				for i = math.max(1, #files - 29), #files do
					table.insert(last_30, files[i])
				end

				local habit_stats = {}
				local habit_names = {}

				for _, file in ipairs(last_30) do
					local date = file:match("(%d%d%d%d%-%d%d%-%d%d)%.md$")
					if date then
						local f = io.open(file, "r")
						if f then
							local in_habits = false
							for line in f:lines() do
								if line:match("^### Habits") then
									in_habits = true
								elseif in_habits and line:match("^###") then
									break
								elseif in_habits then
									local tag, val = line:match("^%- (#%l+) %- (.*)")
									if tag then
										habit_names[tag] = true
										habit_stats[tag] = habit_stats[tag] or {}
										-- simple check: if value is not empty or "0" or "no", consider it done
										local done = val:match("%w") and val ~= "0" and val:lower() ~= "no"
										habit_stats[tag][date] = done
									end
								end
							end
							f:close()
						end
					end
				end

				local output = { "      Habit Tracker (Last 30 Days)", "      " .. string.rep("=", 28), "" }
				local sorted_habits = {}
				for h in pairs(habit_names) do
					table.insert(sorted_habits, h)
				end
				table.sort(sorted_habits)

				for _, habit in ipairs(sorted_habits) do
					local row = string.format(" %-10s: ", habit:gsub("#", ""))
					local dates = {}
					for d in pairs(habit_stats[habit]) do
						table.insert(dates, d)
					end
					table.sort(dates)

					for _, d in ipairs(dates) do
						row = row .. (habit_stats[habit][d] and "●" or "○")
					end
					table.insert(output, row)
				end
				table.insert(output, "")
				table.insert(output, " ● = Done, ○ = Missed")

				local width = 50
				local height = #output + 2
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
				vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
				vim.api.nvim_buf_set_option(bufnr, "filetype", "text")

				local opts = {
					relative = "editor",
					width = width,
					height = height,
					col = (vim.o.columns - width) / 2,
					row = (vim.o.lines - height) / 2,
					style = "minimal",
					border = "rounded",
					title = " Habit Consistency ",
					title_pos = "center",
				}
				vim.api.nvim_open_win(bufnr, true, opts)
				vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":q<CR>", { noremap = true, silent = true })
				vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
			end,
			desc = "Habit Tracker",
		},
		-- Extra Note Management
		{ mode = "n", "<leader>oe", ":ExpenseSummary<CR>", desc = "Expense Summary" },
		{ mode = "n", "<leader>ow", ":lua require('config.expense_formatter').add_expense()<CR>", desc = "Quick Expense" },
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
			default = new_note_template,
		},
		----------------------------------------------------------------
		-- Filename / ID generation: slug format (foo-bar.md)
		----------------------------------------------------------------
		-- 1. This tells the plugin: "Use the title I typed as the ID/Filename"
		note_id_func = function(title)
			local name = ""
			if title ~= nil then
				name = title:gsub(" ", "-"):lower()
			else
				name = tostring(os.time())
			end
			-- Always prefix with date if it's not a dot-nested name
			if not name:match("%.") then
				return os.date("%Y-%m-%d-") .. name
			end
			return name
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
		ui = { enable = false },
	},
}
