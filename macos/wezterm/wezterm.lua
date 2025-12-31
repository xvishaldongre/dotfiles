local wezterm = require("wezterm")
local config = {}

-- base config
config = {
	default_prog = { "zsh", "-l", "-c", "tmux new-session -A -s 0" },
	adjust_window_size_when_changing_font_size = false,
	color_scheme = "tokyonight_night",
	font_size = 13,
	-- font = wezterm.font("FiraCode Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
	max_fps = 240,
	hide_tab_bar_if_only_one_tab = true,
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

	keys = {
		{
			key = "q",
			mods = "CMD",
			action = wezterm.action.QuitApplication,
		},
		{
			key = "v",
			mods = "CMD",
			action = wezterm.action.PasteFrom("Clipboard"),
		},
		{
			key = "=",
			mods = "CMD",
			action = wezterm.action.IncreaseFontSize,
		},
		{
			key = "-",
			mods = "CMD",
			action = wezterm.action.DecreaseFontSize,
		},
		{
			key = "0",
			mods = "CMD",
			action = wezterm.action.ResetFontSize,
		},
		{
			key = "y",
			mods = "CMD",
			action = wezterm.action.QuickSelectArgs({
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
	mouse_bindings = {
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}

-- Extra Cmd+<key> → tmux mappings
local tmux_prefix = "\x00" -- Cmd+Space = NUL
local tmux_keys = { "h", "j", "k", "l", ";" }

for _, char in ipairs(tmux_keys) do
	-- lowercase
	table.insert(config.keys, {
		key = char,
		mods = "CMD",
		action = wezterm.action.SendString(tmux_prefix .. char),
	})
	-- uppercase
	local upper = string.upper(char)
	table.insert(config.keys, {
		key = upper,
		mods = "CMD",
		action = wezterm.action.SendString(tmux_prefix .. upper),
	})
end

return config
