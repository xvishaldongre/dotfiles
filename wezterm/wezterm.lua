local wezterm = require 'wezterm'
return {
	-- color_scheme = 'termnial.sexy',
	-- color_scheme = 'Catppuccin Macchiato', 
	-- default_prog = { 'bash','-l' },

	default_prog = { '/opt/homebrew/bin/zellij'},

	
	color_scheme = 'OneHalfDark',
	-- enable_tab_kgr = false,
	font_size = 14.0,
	-- font = wezterm.font('JetBrains Mono'),
	font = wezterm.font('FiraCode Nerd Font Mono',{ weight = 600, stretch = "Normal", style = "Normal" }),
	-- font = wezterm.font(''),
	 
	-- macos_window_background_blur = 40,
	hide_tab_bar_if_only_one_tab = true,
	window_background_image = '/Users/vishal.dongre/Downloads/term.png',

	initial_cols = 140,
	initial_rows = 45,

	 

	-- window_padding = {
	-- 	left = 0,
	-- 	right = 0,
	--   },
	
	window_background_image_hsb = {
		brightness = .35,
	},
	window_background_opacity = 1,
	-- window_background_opacity = 0.78,
	-- window_background_opacity = 0.20,
	window_decorations = 'RESIZE',
	keys = {
		{
			key = 'f',
			mods = 'CTRL',
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = 'd',
			mods = 'SUPER',
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = 'd',
			mods = 'SUPER|SHIFT',
			
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
	},
	mouse_bindings = {
	  -- Ctrl-click will open the link under the mouse cursor
	  {
	    event = { Up = { streak = 1, button = 'Left' } },
	    mods = 'CTRL',
	    action = wezterm.action.OpenLinkAtMouseCursor,
	  },
	},
}

