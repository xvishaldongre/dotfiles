local wezterm = require("wezterm")
-- wezterm.on("gui-startup", function(cmd)
--   local screen = wezterm.gui.screens().active
-- --   local ratio = 1
--   local width = screen.width * 1
--   local height = screen.height * 0.8

--   local tab, pane, window = wezterm.mux.spawn_window({
--     position = {
--       x = (screen.width - width) / 2,
--       y = 0,
--       origin = 'ActiveScreen',
--     },
--     -- You can optionally pass the startup command here
--     -- workspace = 'default',
--     -- cwd = wezterm.home_dir,
--   })

--   window:gui_window():set_inner_size(width, height)
-- end)
return {
	-- color_scheme = 'termnial.sexy',
	-- color_scheme = 'Catppuccin Macchiato',
	-- default_prog = { 'bash','-l' },

	default_prog = { "/opt/homebrew/bin/zellij" },
	adjust_window_size_when_changing_font_size = false,
	-- color_scheme = 'OneHalfDark',
	color_scheme = "tokyonight_night",

	-- enable_tab_kgr = false,
	font_size = 13,
	-- font = wezterm.font('JetBrains Mono'),
	font = wezterm.font("FiraCode Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
	-- font = wezterm.font(''),
	max_fps = 240,
	-- macos_window_background_blur = 40,
	hide_tab_bar_if_only_one_tab = true,
	-- window_background_image = '/Users/vishal.dongre/Downloads/term.png',
	window_background_image = "/Users/vishal.dongre/Downloads/asdf.jpg",

	initial_cols = 180,
	initial_rows = 45,

	-- window_padding = {
	-- 	left = 0,
	-- 	right = 0,
	--   },

	treat_left_ctrlalt_as_altgr = true,

	window_background_image_hsb = {
		brightness = 0.020,
	},
	window_background_opacity = 1,
	-- window_background_opacity = 0.78,
	-- window_background_opacity = 0.20,
	window_decorations = "RESIZE",
	disable_default_key_bindings = true,
	-- send_composed_key_when_left_alt_is_pressed = true,
	-- send_composed_key_when_right_alt_is_pressed = true,
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
			key = "h",
			mods = "ALT",
			action = wezterm.action_callback(function()
				os.execute("zellij action new-pane --direction right && zellij action move-pane left")
			end),
		},
		{
			key = "l",
			mods = "ALT",
			action = wezterm.action_callback(function()
				os.execute("zellij action new-pane --direction right")
			end),
		},
		{
			key = "j",
			mods = "ALT",
			action = wezterm.action_callback(function()
				os.execute("zellij action new-pane --direction down")
			end),
		},
		{
			key = "k",
			mods = "ALT",
			action = wezterm.action_callback(function()
				os.execute("zellij action new-pane --direction down && zellij action move-pane up")
			end),
		},
		{
			key = "t",
			mods = "ALT",
			action = wezterm.action_callback(function()
				local session = os.getenv("ZELLIJ_SESSION_NAME") or "unknown"
				os.execute("echo 'Current session: " .. session .. "' > ~/test.txt")
			end),
		},
	},

	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
