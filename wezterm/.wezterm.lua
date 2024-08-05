-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'rose-pine'
config.window_background_opacity = .99

config.font = wezterm.font('Fira Code', { weight = 'Regular' })
config.font_size = 12.2


config.default_cwd = "/home/pjt727/coding"

-- startup dim
config.initial_cols = 130
config.initial_rows = 40
config.window_decorations = "RESIZE"

--colors
config.colors = {
    -- cursor_bg = "#ff0000",         -- Set the highlight color to red
    -- cursor_border = "#ff0000",     -- Set the border color of the cursor to red
    selection_bg = "#cecacd", -- Set the selection background color to red
    selection_fg = "#d7827e", -- Set the selection text color to white
}


-- key rebinds
config.keys = {
    {
        key = 't',
        mods = 'CTRL',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain'
    },
    {
        key = 'k',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateCopyMode
    },
}
return config
