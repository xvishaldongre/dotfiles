local M = {}

function M.format_expenses()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local new_lines = {}
	local i = 1

	while i <= #lines do
		local line = lines[i]
		-- Match lines like "  - 187| zepto" or "- 123 |"
		local indent, content = line:match("^(%s*)(%- %d+%s*|.*)")

		if content then
			local expense_block = {}
			local block_total = 0

			-- Collect contiguous expense lines
			while i <= #lines do
				local cur_indent, cur_content = lines[i]:match("^(%s*)(%- %d+%s*|.*)")
				if not cur_content then
					break
				end
				table.insert(expense_block, { indent = cur_indent, content = cur_content })
				i = i + 1
			end

			-- Parse and format the block
			local parsed_lines = {}
			local max_widths = { 0, 0, 0 } -- amount, to, category

			for _, entry in ipairs(expense_block) do
				local parts = {}
				local raw_parts = vim.split(entry.content, "|", { trimempty = false })
				for _, p in ipairs(raw_parts) do
					table.insert(parts, vim.trim(p))
				end

				if #parts >= 2 then
					local amt_str = parts[1]:match("%d+")
					if amt_str then
						block_total = block_total + tonumber(amt_str)
					end

					table.insert(parsed_lines, { indent = entry.indent, parts = parts })
					max_widths[1] = math.max(max_widths[1], #parts[1])
					max_widths[2] = math.max(max_widths[2], #parts[2])
					if #parts >= 3 then
						max_widths[3] = math.max(max_widths[3], #parts[3])
					end
				else
					table.insert(new_lines, entry.indent .. entry.content)
				end
			end

			-- Reconstruct formatted lines
			local last_indent = ""
			for _, entry in ipairs(parsed_lines) do
				last_indent = entry.indent
				local formatted = string.format(
					"%s%- " .. max_widths[1] .. "s | %- " .. max_widths[2] .. "s",
					entry.indent,
					entry.parts[1],
					entry.parts[2]
				)

				if #entry.parts >= 3 then
					formatted = string.format("%s | %- " .. max_widths[3] .. "s", formatted, entry.parts[3])
				end

				-- Add remaining parts if any
				if #entry.parts > 3 then
					for k = 4, #entry.parts do
						if k < #entry.parts or entry.parts[k] ~= "" then
							formatted = formatted .. " | " .. entry.parts[k]
						end
					end
				end
				table.insert(new_lines, formatted)
			end

			-- Add or update Total line
			local total_line = string.format("%s**Total: %d**", last_indent, block_total)
			if i <= #lines and lines[i]:match("^%s*%*%*Total: %d+%%*%*") then
				i = i + 1 -- Skip existing total line
			end
			table.insert(new_lines, total_line)
		else
			table.insert(new_lines, line)
			i = i + 1
		end
	end

	-- Only update if changed
	local changed = false
	if #new_lines == #lines then
		for idx = 1, #lines do
			if new_lines[idx] ~= lines[idx] then
				changed = true
				break
			end
		end
	else
		changed = true
	end

	if changed then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
	end
end

function M.show_summary()
	local daily_dir = vim.fn.expand("~/shared/notes/daily")
	local files = vim.fn.globpath(daily_dir, "*.md", false, true)
	local categories = {}
	local recipients = {}
	local total_all = 0

	-- Get current month/year for the header
	local current_month_year = os.date("%B %Y")

	for _, file in ipairs(files) do
		local f = io.open(file, "r")
		if f then
			for line in f:lines() do
				local content = line:match("^%s*%- %d+%s*|.*")
				if content then
					local parts = vim.split(content, "|", { trimempty = true })
					if #parts >= 3 then
						local amt = tonumber(vim.trim(parts[1]):match("%d+"))
						local to = vim.trim(parts[2])
						local cat_part = vim.trim(parts[3])
						-- Extract category from "#category - items"
						local cat = cat_part:match("^(#[%w%-_]+)") or cat_part

						if amt then
							categories[cat] = (categories[cat] or 0) + amt
							recipients[to] = (recipients[to] or 0) + amt
							total_all = total_all + amt
						end
					end
				end
			end
			f:close()
		end
	end

	-- Prepare summary content
	local output = {
		"      Financial Snapshot - " .. current_month_year,
		"      " .. string.rep("=", #current_month_year + 23),
		"",
		" Categorical Breakdown",
		" ---------------------",
	}

	local function add_sorted_table(data, label, limit)
		local sorted = {}
		for k, v in pairs(data) do
			table.insert(sorted, { name = k, amount = v })
		end
		table.sort(sorted, function(a, b)
			return a.amount > b.amount
		end)

		for idx, item in ipairs(sorted) do
			if limit and idx > limit then
				break
			end
			table.insert(output, string.format(" %-20s : %d", item.name, item.amount))
		end
	end

	add_sorted_table(categories)

	table.insert(output, "")
	table.insert(output, " Top Recipients")
	table.insert(output, " --------------")
	add_sorted_table(recipients, nil, 10) -- Show top 10

	table.insert(output, "")
	table.insert(output, string.rep("-", 30))
	table.insert(output, string.format(" %-20s : %d", "TOTAL SPENDING", total_all))
	table.insert(output, string.rep("-", 30))

	-- Show in floating window
	local width = 50
	local height = #output + 2
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " Financial Snapshot ",
		title_pos = "center",
	}
	vim.api.nvim_open_win(bufnr, true, opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

function M.add_expense()
	vim.ui.input({ prompt = "Amount: " }, function(amount)
		if not amount or amount == "" then
			return
		end
		vim.ui.input({ prompt = "To: " }, function(to)
			if not to or to == "" then
				return
			end
			vim.ui.input({ prompt = "Category (e.g. #food): " }, function(cat)
				if not cat or cat == "" then
					return
				end
				vim.ui.input({ prompt = "Items: " }, function(items)
					local line = string.format("- %s | %s | %s - %s", amount, to, cat, items or "")
					-- Find Expenses section
					local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
					local expense_idx = -1
					for idx, l in ipairs(lines) do
						if l:match("^### Expenses") then
							expense_idx = idx
							break
						end
					end

					if expense_idx ~= -1 then
						-- Insert after the header or after existing items
						local insert_at = expense_idx + 1
						while insert_at <= #lines and (lines[insert_at]:match("^%s*%-") or lines[insert_at] == "") do
							insert_at = insert_at + 1
						end
						vim.api.nvim_buf_set_lines(0, insert_at - 1, insert_at - 1, false, { "  " .. line })
						-- Trigger format and save
						vim.cmd("w")
					else
						vim.notify("Expenses section not found!", vim.log.levels.WARN)
					end
				end)
			end)
		end)
	end)
end

function M.show_yearly_summary()
	local daily_dir = vim.fn.expand("~/shared/notes/daily")
	local files = vim.fn.globpath(daily_dir, "*.md", false, true)
	local months = {}
	local categories = {}
	local recipients = {}
	local total_all = 0
	local current_year = os.date("%Y")

	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t")
		local year, month = filename:match("^(%d%d%d%d)-(%d%d)-%d%d%.md$")

		if year == current_year then
			local month_name = os.date("%B", os.time({ year = year, month = month, day = 1 }))
			local f = io.open(file, "r")
			if f then
				for line in f:lines() do
					local content = line:match("^%s*%- %d+%s*|.*")
					if content then
						local parts = vim.split(content, "|", { trimempty = true })
						if #parts >= 3 then
							local amt = tonumber(vim.trim(parts[1]):match("%d+"))
							local to = vim.trim(parts[2])
							local cat_part = vim.trim(parts[3])
							local cat = cat_part:match("^(#[%w%-_]+)") or cat_part

							if amt then
								months[month_name] = (months[month_name] or 0) + amt
								categories[cat] = (categories[cat] or 0) + amt
								recipients[to] = (recipients[to] or 0) + amt
								total_all = total_all + amt
							end
						end
					end
				end
				f:close()
			end
		end
	end

	-- Prepare summary content
	local output = {
		"      Yearly Financial Snapshot - " .. current_year,
		"      " .. string.rep("=", #current_year + 34),
		"",
		" Monthly Totals",
		" --------------",
	}

	-- Add months in order
	local month_order = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December",
	}
	for _, m in ipairs(month_order) do
		if months[m] then
			table.insert(output, string.format(" %-20s : %d", m, months[m]))
		end
	end

	table.insert(output, "")
	table.insert(output, " Categorical Breakdown")
	table.insert(output, " ---------------------")

	local function add_sorted_table(data, limit)
		local sorted = {}
		for k, v in pairs(data) do
			table.insert(sorted, { name = k, amount = v })
		end
		table.sort(sorted, function(a, b)
			return a.amount > b.amount
		end)

		for idx, item in ipairs(sorted) do
			if limit and idx > limit then
				break
			end
			table.insert(output, string.format(" %-20s : %d", item.name, item.amount))
		end
	end

	add_sorted_table(categories)

	table.insert(output, "")
	table.insert(output, " Top Recipients")
	table.insert(output, " --------------")
	add_sorted_table(recipients, 10)

	table.insert(output, "")
	table.insert(output, string.rep("-", 30))
	table.insert(output, string.format(" %-20s : %d", "TOTAL YEARLY", total_all))
	table.insert(output, string.rep("-", 30))

	-- Show in floating window
	local width = 60
	local height = math.min(#output + 2, vim.o.lines - 4)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " Yearly Financial Snapshot ",
		title_pos = "center",
	}
	vim.api.nvim_open_win(bufnr, true, opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
end

function M.generate_monthly_markdown_report()
	local daily_dir = vim.fn.expand("~/shared/notes/daily")
	local files = vim.fn.globpath(daily_dir, "*.md", false, true)
	local data = {} -- key: YYYY-MM, value: {month_name, categories = {}, recipients = {}, total = 0}

	for _, file in ipairs(files) do
		local filename = vim.fn.fnamemodify(file, ":t")
		local year, month = filename:match("^(%d%d%d%d)-(%d%d)-%d%d%.md$")
		if year and month then
			local key = year .. "-" .. month
			if not data[key] then
				local m_time = os.time({ year = year, month = month, day = 1 })
				local month_name = os.date("%B %Y", m_time)
				data[key] = { month_name = month_name, categories = {}, recipients = {}, total = 0 }
			end

			local f = io.open(file, "r")
			if f then
				for line in f:lines() do
					local match_content = line:match("^%s*%- [%d%.]+%s*|.*")
					if match_content then
						local parts = vim.split(line, "|", { trimempty = true })
						if #parts >= 3 then
							local amt_part = vim.trim(parts[1]):match("[%d%.]+")
							local amt = tonumber(amt_part)
							local to = vim.trim(parts[2])
							local cat_part = vim.trim(parts[3])
							local cat = cat_part:match("^(#[%w%-_]+)") or cat_part

							if amt then
								data[key].categories[cat] = (data[key].categories[cat] or 0) + amt
								data[key].recipients[to] = (data[key].recipients[to] or 0) + amt
								data[key].total = data[key].total + amt
							end
						end
					end
				end
				f:close()
			end
		end
	end

	local sorted_keys = {}
	for k in pairs(data) do
		table.insert(sorted_keys, k)
	end
	table.sort(sorted_keys)

	local lines = { "# Monthly Expense Overview", "", "Generated on " .. os.date("%Y-%m-%d %H:%M:%S"), "" }

	local function format_section_list(items)
		local max_amt_len = 0
		for _, item in ipairs(items) do
			max_amt_len = math.max(max_amt_len, #tostring(item[2]))
		end

		local section_lines = {}
		for _, item in ipairs(items) do
			table.insert(section_lines, string.format("- %-" .. max_amt_len .. "d | %s", item[2], item[1]))
		end
		return section_lines
	end

	local previous_total = 0
	for _, key in ipairs(sorted_keys) do
		local m_data = data[key]
		local total_line = string.format("**Total Spending: %d**", m_data.total)
		
		if previous_total > 0 then
			local delta = ((m_data.total - previous_total) / previous_total) * 100
			local arrow = delta >= 0 and "↑" or "↓"
			total_line = total_line .. string.format(" (%s %.1f%% from last month)", arrow, math.abs(delta))
		end
		previous_total = m_data.total

		table.insert(lines, "## " .. m_data.month_name)
		table.insert(lines, total_line)
		table.insert(lines, "")
		table.insert(lines, "### Categorical Breakdown")

		local cats = {}
		for cat, amt in pairs(m_data.categories) do
			table.insert(cats, { cat, amt })
		end
		table.sort(cats, function(a, b)
			return a[2] > b[2]
		end)
		vim.list_extend(lines, format_section_list(cats))

		table.insert(lines, "")
		table.insert(lines, "### Top Recipients")

		local recs = {}
		for to, amt in pairs(m_data.recipients) do
			table.insert(recs, { to, amt })
		end
		table.sort(recs, function(a, b)
			return a[2] > b[2]
		end)

		local limited_recs = {}
		for idx, r in ipairs(recs) do
			if idx > 15 then
				break
			end
			table.insert(limited_recs, r)
		end
		vim.list_extend(lines, format_section_list(limited_recs))

		table.insert(lines, "")
		table.insert(lines, "---")
		table.insert(lines, "")
	end

	-- Create a new scratch buffer
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
	vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_name(bufnr, "Monthly_Overview_" .. os.date("%Y%m%d"))

	-- Open in a split
	vim.cmd("vsplit")
	vim.api.nvim_set_current_buf(bufnr)
end

return M
