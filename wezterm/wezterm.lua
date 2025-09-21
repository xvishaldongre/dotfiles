local wezterm = require("wezterm")

return {
    -- Font settings
    font = wezterm.font("FiraCode Nerd Font Mono", { weight = 600, stretch = "Normal", style = "Normal" }),
    font_size = 10,

    -- Terminal size
    initial_cols = 180,
    initial_rows = 45,

    -- Color scheme
    color_scheme = "tokyonight_night",

    -- Window background
    window_background_image = os.getenv("HOME") .. "/Downloads/blackhole.jpg",
    window_background_image_hsb = {
        brightness = 0.02,
    },
    window_background_opacity = 1.0,
    adjust_window_size_when_changing_font_size = false,

    -- Window decorations (show full title bar with close, minimize, maximize)
    window_decorations = "RESIZE",

    -- Tab bar behavior
    hide_tab_bar_if_only_one_tab = true,

    -- Keyboard behavior
    treat_left_ctrlalt_as_altgr = true,
    enable_kitty_keyboard = true,
    disable_default_key_bindings = false,

    -- Key bindings
    keys = {
        { key = "v", mods = "CMD", action = wezterm.action.PasteFrom("Clipboard") },
        { key = "=", mods = "CMD", action = wezterm.action.IncreaseFontSize },
        { key = "-", mods = "CMD", action = wezterm.action.DecreaseFontSize },
        { key = "0", mods = "CMD", action = wezterm.action.ResetFontSize },
        {
            key = "y",
            mods = "CMD",
            action = wezterm.action.QuickSelectArgs({
                patterns = {
                    [["([^"]{7,})"]],                   -- double quotes
                    [[\'([^\']{7,})\']],                -- single quotes
                    [[\b\w+://[^\s"']{7,}]],            -- URLs
                    [[~?/?(?:[\w\.-]+/)*[\w\.-]{7,}]],  -- absolute/home paths
                    [[\.\./(?:[\w\.-]+/)*[\w\.-]{7,}]], -- relative paths
                    [[\b[\w-]{7,}\b]],                  -- long/hyphenated words
                },
                scope_lines = 0,
            }),
        },
    },

    -- Mouse bindings
    mouse_bindings = {
        {
            event = { Up = { streak = 1, button = "Left" } },
            mods = "CTRL",
            action = wezterm.action.OpenLinkAtMouseCursor,
        },
    },

    -- Performance
    max_fps = 240,
}
