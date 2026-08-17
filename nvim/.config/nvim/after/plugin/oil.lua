require("oil").setup({
    keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = false,
        ["<C-c>"] = false,
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        ["<leader>yr"] = {
            desc = "Copy relative path to clipboard",
            callback = function()
                local oil = require("oil")
                local entry = oil.get_cursor_entry()
                local dir = oil.get_current_dir()

                if not entry or not dir then
                    return
                end

                -- Get directory path relative to the current working directory (cwd)
                local rel_dir = vim.fn.fnamemodify(dir, ":.")
                local rel_path = rel_dir .. entry.name

                -- Copy the result to the system clipboard register (+)
                vim.fn.setreg("+", rel_path)
                print("Copied relative path: " .. rel_path)
            end,
        },
    }
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
