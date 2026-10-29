local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- Tokyo Night accents, picked to match the old tmux status line
local palette = {
	blue = "#7aa2f7",
	dim = "#565f89",
	green = "#9ece6a",
	text = "#c0caf5",
	clear = "rgba(0, 0, 0, 0)",
}

-- WezTerm cannot centre its tab bar natively. When true, the first tab gets a
-- left padding that is recomputed on every tab bar repaint, which puts the tab
-- list in the middle of the window like tmux status-justify centre.
-- The padded area is still part of tab 1, so clicking it activates tab 1.
local center_tabs = true

-- Close the current tab, but never the last tab (that would close the window
-- and quit WezTerm).
local function close_tab(window, pane)
	local tabs = window:mux_window():tabs()
	if #tabs > 1 then
		window:perform_action(act.CloseCurrentTab({ confirm = true }), pane)
	end
end

-- Close a pane, but never the last pane of the last tab.
local function close_pane(window, pane)
	local tabs = window:mux_window():tabs()
	if #tabs == 1 and #window:active_tab():panes() <= 1 then
		return
	end
	window:perform_action(act.CloseCurrentPane({ confirm = true }), pane)
end

-- New tab in the current directory
local function new_tab(window, pane)
	local uri = pane:get_current_working_dir()
	window:perform_action(
		act.SpawnCommandInNewTab({
			domain = "CurrentPaneDomain",
			cwd = uri and uri.file_path or nil,
		}),
		pane
	)
end

local function rename_tab(window, pane)
	window:perform_action(
		act.PromptInputLine({
			description = "Rename tab:",
			action = wezterm.action_callback(function(w, _, line)
				if line and line ~= "" then
					w:active_tab():set_title(line)
				end
			end),
		}),
		pane
	)
end

local function rename_session(window, pane)
	local old = window:active_workspace()
	window:perform_action(
		act.PromptInputLine({
			description = "Rename session:",
			action = wezterm.action_callback(function(_, _, line)
				if line and line ~= "" then
					wezterm.mux.rename_workspace(old, line)
				end
			end),
		}),
		pane
	)
end

-- Create a session (workspace) and ask for its name
local function new_session(window, pane)
	local cwd = nil
	local uri = pane:get_current_working_dir()
	if uri then
		cwd = uri.file_path
	end

	window:perform_action(
		act.PromptInputLine({
			description = "New session name:",
			action = wezterm.action_callback(function(w, p, line)
				if line == nil or line == "" then
					return
				end
				w:perform_action(act.SwitchToWorkspace({
					name = line,
					spawn = { cwd = cwd },
				}), p)
			end),
		}),
		pane
	)
end

-- Toggle the "notes" session and back, like common/tmux/toggle-notes.sh.
local notes_workspace = "notes"
local last_workspace = nil

local function toggle_notes(window, pane)
	local active = window:active_workspace()
	if active == notes_workspace then
		local target = last_workspace or "default"
		window:perform_action(act.SwitchToWorkspace({ name = target }), pane)
	else
		last_workspace = active
		window:perform_action(act.SwitchToWorkspace({ name = notes_workspace }), pane)
	end
end

-- Session switcher: workspaces (sessions) plus zoxide paths, like
-- common/tmux/session-v2.sh. Fuzzy list, Enter to select.
-- Icons are the same Nerd Font glyphs that session-v2.sh uses.
local icon_session = ""
local icon_folder = ""

local function choice(color, icon, text)
	return wezterm.format({
		{ Foreground = { AnsiColor = color } },
		{ Text = "  " .. icon },
		{ Foreground = { Color = palette.text } },
		{ Text = " " .. text },
	})
end

local function session_switcher(window, pane)
	local choices = {
		{
			id = "new",
			label = wezterm.format({
				{ Foreground = { AnsiColor = "Green" } },
				{ Text = "  [+]" },
				{ Foreground = { Color = palette.text } },
				{ Text = " New session" },
			}),
		},
	}

	local active = window:active_workspace()
	local names = wezterm.mux.get_workspace_names()
	table.sort(names)
	for _, name in ipairs(names) do
		table.insert(choices, {
			id = "ws:" .. name,
			label = choice("Blue", icon_session, "[S] " .. name .. (name == active and " *" or "")),
		})
	end

	local ok, stdout = wezterm.run_child_process({ "zoxide", "query", "-l" })
	if ok and stdout then
		local home = wezterm.home_dir
		for path in stdout:gmatch("[^\r\n]+") do
			local display = path
			if path:sub(1, #home) == home then
				display = "~" .. path:sub(#home + 1)
			end
			table.insert(choices, {
				id = "path:" .. path,
				label = choice("Yellow", icon_folder, "[P] " .. display),
			})
		end
	end

	window:perform_action(
		act.InputSelector({
			title = "Sessions",
			choices = choices,
			fuzzy = true,
			fuzzy_description = "Session > ",
			action = wezterm.action_callback(function(w, p, id)
				if id == nil then
					return
				end
				if id == "new" then
					new_session(w, p)
					return
				end

				local kind, value = id:match("^(%a+):(.*)$")
				if kind == "ws" then
					w:perform_action(act.SwitchToWorkspace({ name = value }), p)
				elseif kind == "path" then
					local name = value:match("([^/]+)$") or value
					if name == "" then
						name = "root"
					end
					if #name > 36 then
						name = name:sub(1, 34) .. ".."
					end
					w:perform_action(act.SwitchToWorkspace({
						name = name,
						spawn = { cwd = value },
					}), p)
				end
			end),
		}),
		pane
	)
end

-- tmux prefix: Ctrl+Space opens a one-shot key table (see config.key_tables
-- below). Unlike the built-in `leader`, a key table can be queried with
-- window:active_key_table(), which is what lets us paint tmux's [P] badge.
local prefix_badge = wezterm.format({
	{ Background = { Color = "#e0af68" } },
	{ Foreground = { Color = "#1a1b26" } },
	{ Text = " [P] " },
})

-- Zoom badge, like tmux's window_zoomed_flag
local zoom_badge = wezterm.format({
	{ Background = { Color = "#7aa2f7" } },
	{ Foreground = { Color = "#1a1b26" } },
	{ Text = " [Z] " },
})

-- Both badge slots are always reserved (blank when idle) so the centred tabs
-- do not jump when a badge appears. The tab bar also keeps a small gutter next
-- to the left status, so centring needs a few extra cells; the value below was
-- measured against screenshots with 1, 2 and 3 tabs.
local badge_slot = 5
local centring_gutter = 10
local left_slot = badge_slot * 2

local function prefix_pending(window)
	local ok, name = pcall(function()
		return window:active_key_table()
	end)
	return ok and name == "prefix"
end

local function pane_zoomed(window)
	local ok, zoomed = pcall(function()
		for _, info in ipairs(window:active_tab():panes_with_info()) do
			if info.is_zoomed then
				return true
			end
		end
		return false
	end)
	return ok and zoomed
end

local function sync_left_status(window)
	pcall(function()
		local badges = {}
		if prefix_pending(window) then
			table.insert(badges, prefix_badge)
		end
		if pane_zoomed(window) then
			table.insert(badges, zoom_badge)
		end
		-- Pack the badges to the left, then pad to the reserved width so the
		-- centred tabs never move. tmux does the same with status-left-length.
		local pad = left_slot - badge_slot * #badges
		window:set_left_status(table.concat(badges) .. string.rep(" ", pad))
	end)
end

local function enter_prefix(window, pane)
	window:perform_action(
		act.ActivateKeyTable({
			name = "prefix",
			one_shot = true,
			timeout_milliseconds = 1000,
		}),
		pane
	)
	sync_left_status(window)
	-- One-shot tables also expire on their own; resync once they are gone.
	wezterm.time.call_after(1.1, function()
		sync_left_status(window)
	end)
end

-- base config
config = {
	-- Native WezTerm: tmux is no longer started.
	-- To go back to tmux, comment the next line and uncomment the one after it.
	default_prog = { "zsh", "-l" },
	-- default_prog = { "zsh", "-l", "-c", "tmux new-session -A -s 0" },
	adjust_window_size_when_changing_font_size = false,
	color_scheme = "tokyonight_night",
	font_size = 13,
	-- font = wezterm.font("FiraCode Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
	max_fps = 240,
	window_background_image = wezterm.config_dir .. "/asdf.jpg",
	initial_cols = 180,
	initial_rows = 45,
	treat_left_ctrlalt_as_altgr = true,
	window_background_image_hsb = {
		brightness = 0.020,
	},
	window_background_opacity = 1,
	window_decorations = "RESIZE",
	disable_default_key_bindings = true,
	enable_kitty_keyboard = true,

	-- Repaint the bar often so the prefix badge clears quickly after a key.
	status_update_interval = 250,

	-- A little breathing room: above the tab bar and below it
	window_frame = {
		border_top_height = 16,
		border_top_color = palette.clear,
	},
	window_padding = {
		top = 16,
		bottom = 16,
		left = 16,
		right = 16,
	},

	-- Tab bar styled like the tmux status line: top, transparent, no buttons
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = false,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	show_tab_index_in_tab_bar = false, -- index is added by format-tab-title
	show_new_tab_button_in_tab_bar = false,
	tab_max_width = center_tabs and 1024 or 16,
	status_update_interval = 500,

	colors = {
		tab_bar = {
			background = palette.clear,
			active_tab = {
				bg_color = palette.clear,
				fg_color = palette.blue,
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = palette.clear,
				fg_color = palette.dim,
			},
			inactive_tab_hover = {
				bg_color = palette.clear,
				fg_color = palette.text,
			},
			new_tab = {
				bg_color = palette.clear,
				fg_color = palette.dim,
			},
			new_tab_hover = {
				bg_color = palette.clear,
				fg_color = palette.text,
			},
			inactive_tab_edge = palette.clear,
		},
	},

	keys = {
		--- application ---
		{ key = "q", mods = "CMD", action = act.QuitApplication },
		{ key = "n", mods = "CMD", action = act.SpawnWindow },
		{ key = "r", mods = "CMD", action = act.ReloadConfiguration },

		--- sessions (workspaces): Alt+; was the tmux session popup ---
		{ key = ";", mods = "ALT", action = wezterm.action_callback(session_switcher) },
		{ key = "S", mods = "CMD|SHIFT", action = wezterm.action_callback(session_switcher) },
		{ key = "N", mods = "CMD|SHIFT", action = wezterm.action_callback(new_session) },

		--- tabs ---
		{ key = "t", mods = "CMD", action = wezterm.action_callback(new_tab) },
		{ key = "w", mods = "CMD", action = wezterm.action_callback(close_tab) },
		{ key = "]", mods = "CMD", action = act.ActivateTabRelative(1) },
		{ key = "[", mods = "CMD", action = act.ActivateTabRelative(-1) },
		{ key = "RightArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
		{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },

		--- panes: same letters as the old tmux prefix ---
		{ key = "d", mods = "CMD", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "D", mods = "CMD|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
		{ key = ";", mods = "CMD", action = act.ActivatePaneDirection("Prev") },
		{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },
		{ key = "x", mods = "CMD", action = wezterm.action_callback(close_pane) },
		{ key = "H", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 2 }) },
		{ key = "J", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "K", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "L", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 2 }) },

		--- tmux prefix (Ctrl+Space) ---
		{ key = "Space", mods = "CTRL", action = wezterm.action_callback(enter_prefix) },
		--- notes toggle (Ctrl+O in the old tmux config) ---
		{ key = "o", mods = "CTRL", action = wezterm.action_callback(toggle_notes) },

		--- clipboard ---
		{ key = "c", mods = "CMD", action = act.CopyTo("ClipboardAndPrimarySelection") },
		{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

		--- copy mode and search ---
		{ key = "Space", mods = "CMD|SHIFT", action = act.ActivateCopyMode },
		{ key = "f", mods = "CMD", action = act.Search({ CaseInSensitiveString = "" }) },

		--- font ---
		{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
		{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
		{ key = "0", mods = "CMD", action = act.ResetFontSize },

		--- quick select ---
		{
			key = "y",
			mods = "CMD",
			action = act.QuickSelectArgs({
				patterns = {
					[["([^"]{7,})"]],
					[[\'([^\']{7,})\']],
					[[\b\w+://[^\s"']{7,}]],
					[[~?/?(?:[\w\.-]+/)*[\w\.-]{7,}]],
					[[\.\./(?:[\w\.-]+/)*[\w\.-]{7,}]],
					[[\b[\w-]{7,}\b]],
				},
				scope_lines = 0,
			}),
		},
	},

	-- tmux prefix table: active for one key press after Ctrl+Space.
	-- Keys mirror common/tmux/tmux.conf.
	key_tables = {
		prefix = {
			{ key = "c", action = wezterm.action_callback(new_tab) },
			{ key = "r", action = act.ReloadConfiguration },
			{ key = '"', mods = "SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "%", mods = "SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ key = "s", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "h", action = act.ActivatePaneDirection("Left") },
			{ key = "j", action = act.ActivatePaneDirection("Down") },
			{ key = "k", action = act.ActivatePaneDirection("Up") },
			{ key = "l", action = act.ActivatePaneDirection("Right") },
			{ key = "LeftArrow", action = act.ActivatePaneDirection("Left") },
			{ key = "DownArrow", action = act.ActivatePaneDirection("Down") },
			{ key = "UpArrow", action = act.ActivatePaneDirection("Up") },
			{ key = "RightArrow", action = act.ActivatePaneDirection("Right") },
			{ key = "H", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 2 }) },
			{ key = "J", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "K", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "L", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 2 }) },
			{ key = "z", action = act.TogglePaneZoomState },
			{ key = "x", action = wezterm.action_callback(close_pane) },
			{ key = "&", mods = "SHIFT", action = wezterm.action_callback(close_tab) },
			{ key = ";", action = act.ActivatePaneDirection("Prev") },
			{ key = "o", action = act.ActivatePaneDirection("Next") },
			{ key = "[", action = act.ActivateCopyMode },
			{ key = "n", action = act.ActivateTabRelative(1) },
			{ key = "p", action = act.ActivateTabRelative(-1) },
			{ key = "w", action = wezterm.action_callback(session_switcher) },
			{ key = ",", action = wezterm.action_callback(rename_tab) },
			{ key = "$", mods = "SHIFT", action = wezterm.action_callback(rename_session) },
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "Space", mods = "CTRL", action = "PopKeyTable" },
		},
	},
	mouse_bindings = {
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = act.OpenLinkAtMouseCursor,
		},
	},
}

-- Cmd+1..9 and prefix 1..9 switch to that tab, like tmux base-index 1
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CMD",
		action = act.ActivateTab(i - 1),
	})
	table.insert(config.key_tables.prefix, {
		key = tostring(i),
		action = act.ActivateTab(i - 1),
	})
end

-- Tab titles: "1:zsh", with "*" on the active tab, like tmux
local function tab_name(tab)
	local title = tab.tab_title
	if title == nil or title == "" then
		title = (tab.active_pane and tab.active_pane.title) or "shell"
	end
	if #title > 18 then
		title = title:sub(1, 16) .. ".."
	end
	return title
end

local function tab_label(tab)
	return string.format("%d:%s%s", tab.tab_index + 1, tab_name(tab), tab.is_active and "*" or "")
end

-- Width of the tab bar in cells. The bar spans the whole window, while a pane
-- only spans the padded area, so measure the window and cache the result.
-- format-tab-title is synchronous and cannot call the GUI window API.
local bar_columns = {}

local function remember_columns(window, pane)
	local win = window:get_dimensions()
	local pd = pane:get_dimensions()
	if win.pixel_width and win.pixel_width > 0 and pd.cols > 0 and pd.pixel_width and pd.pixel_width > 0 then
		local cell = pd.pixel_width / pd.cols
		bar_columns[window:window_id()] = math.floor(win.pixel_width / cell + 0.5)
	end
end

local function window_columns(tab)
	local cached = bar_columns[tab.window_id]
	if cached then
		return cached
	end

	-- Fallback until the window size is known: use the terminal width.
	local cols = 0
	for _, pane in ipairs(tab.panes or {}) do
		local right = (pane.left or 0) + (pane.width or 0)
		if right > cols then
			cols = right
		end
	end
	return cols
end

wezterm.on("window-resized", function(window, pane)
	pcall(remember_columns, window, pane)
end)

wezterm.on("format-tab-title", function(tab, tabs)
	local label = " " .. tab_label(tab) .. " "

	if not center_tabs or not tabs[1] or tab.tab_index ~= tabs[1].tab_index then
		return label
	end

	local used = 0
	for _, t in ipairs(tabs) do
		used = used + #(" " .. tab_label(t) .. " ")
	end

	local cols = window_columns(tab) - left_slot - centring_gutter
	if cols <= used then
		return label
	end

	return string.rep(" ", math.floor((cols - used) / 2)) .. label
end)

-- Right side of the bar: the workspace name, in green like tmux's #S.
-- Left side: the [P] prefix badge, like tmux's status-left.
wezterm.on("update-status", function(window, pane)
	pcall(remember_columns, window, pane)
	sync_left_status(window)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = palette.green } },
		{ Text = " " .. window:active_workspace() .. " " },
	}))
end)

return config
