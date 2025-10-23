local function remove_prefix_if_exists(str, prefix)
    if str:sub(1, #prefix) == prefix then
        return str:sub(#prefix + 1)
    else
        return str
    end
end

require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
            {
                function()
                    local ft = vim.bo.filetype

                    if ft == "sql" then
                        local hostname_to_env = {}
                        local dev_hostname = os.getenv("DEV_DB")
                        if dev_hostname then
                            hostname_to_env[dev_hostname] = "🏗️ dev"
                        end
                        local qa_hostname = os.getenv("QA_DB")
                        if qa_hostname then
                            hostname_to_env[qa_hostname] = "🧪 qa"
                        end
                        local prod_hostname = os.getenv("PROD_DB")
                        if prod_hostname then
                            hostname_to_env[prod_hostname] = "‼️🚨PROD🚨‼️"
                        end


                        local db = vim.g.db
                        if db == nil then
                            return "db not connected"
                        end

                        if db:find("localhost") or db:find("sqlite") then
                            local _, _, db_name = string.find(db, "/([^/]+)$")
                            return "🏡 " .. db_name
                        end

                        if hostname_to_env[db] then
                            return hostname_to_env[db]
                        end

                        return "unknown db"
                    end
                    return ""
                end,
                color = {
                    -- fg = "#FFD700",
                    gui = "bold"
                },
            },
            "filename"
        },
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_x = { "filetype" },
        lualine_y = {},
        lualine_z = {},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        -- lualine_x = { "location" },
        -- lualine_x = {},
        lualine_y = {},
        -- lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
})
