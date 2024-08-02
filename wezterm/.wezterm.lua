-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'rose-pine'
config.window_background_opacity = .99


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

-- wezterm.on("gui-startup", function(cmd)
--     local screen = wezterm.gui.screens().main
--     local ratio = 0.7
--     local width, height = screen.width * ratio, screen.height * ratio
--     local tab, pane, window = wezterm.mux.spawn_window(cmd or {
--         position = { x = (screen.width - width) / 2, y = (screen.height - height) / 2 },
--     })
--     -- window:gui_window():maximize()
--     window:gui_window():set_inner_size(width, height)
-- end)

-- key rebinds
config.keys = {
    {
        key = 'w',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentTab { confirm = true },
    },
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
-- relook at this to try to get a good close functionality
wezterm.on('mux-is-process-stateful', function(proc)
    -- Just use the default behavior

    wezterm.log_info(proc.command)
    if proc.command == "nvim" or proc.command == "neovim" then
        -- Check if the process is still running
        if proc:poll() then
            return true
        else
            return true
        end
    end
    return false
end)

-- and finally, return the configuration to wezterm
return config
