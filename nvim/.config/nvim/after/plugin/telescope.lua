local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fp", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- database picker

-- Define the environments and their labels
local db_envs = {
    DEV  = "dev 🏗️",
    QA   = "qa 🧪",
    PROD = "‼️🚨PROD🚨‼️",
}
local pickerOptions = {}

-- Loop through and populate vim.g.dbs
for key, label in pairs(db_envs) do
    local value = os.getenv(key .. "_DB")
    if value then
        table.insert(pickerOptions, { name = label, conn = value })
    end
end

vim.g.dbs = pickerOptions

-- how to add databases to the list (you can not mutate the vim.g.dbs table directly)
-- local temp = vim.g.dbs
-- table.insert(temp, { name = "visual name", conn = "db connection" })
-- vim.g.dbs = temp

local function pick_database()
    pickers.new({}, {
        prompt_title = "Select Database",
        finder = finders.new_table({
            results = vim.g.dbs,
            entry_maker = function(entry)
                return {
                    value = entry.conn,
                    display = entry.name,
                    ordinal = entry.name,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.g.db = selection.value
                print("Database set to: " .. selection.display)
            end)
            return true
        end,
    }):find()
end

vim.keymap.set("n", "<leader>dl", pick_database, { desc = "Pick a database" })
