local wezterm = require("wezterm")
return {
    -- color_scheme = 'termnial.sexy',
    -- color_scheme = 'Catppuccin Macchiato',
    -- default_prog = { 'bash','-l' },
    -- default_prog = {
    --     "/opt/homebrew/bin/zellij",
    --     "attach",
    --     "--create",
    --     "Default",
    -- },
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
    disable_default_key_bindings = false,
    -- send_composed_key_when_left_alt_is_pressed = true,
    -- send_composed_key_when_right_alt_is_pressed = true,
    enable_kitty_keyboard = true,
    keys = {
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
                    -- Inside double quotes only (length > 6)
                    [["([^"]{7,})"]],

                    -- Inside single quotes only (length > 6)
                    [[\'([^\']{7,})\']],

                    -- URLs like postgres://... (value itself > 6 chars)
                    [[\b\w+://[^\s"']{7,}]],

                    -- File system paths (home/absolute) with final part > 6 chars
                    [[~?/?(?:[\w\.-]+/)*[\w\.-]{7,}]],

                    -- Relative paths (../..) where final part > 6 chars
                    [[\.\./(?:[\w\.-]+/)*[\w\.-]{7,}]],

                    -- Hyphenated or long words > 6 characters
                    [[\b[\w-]{7,}\b]],
                },
                scope_lines = 0,
            }),
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
