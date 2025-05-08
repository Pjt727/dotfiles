local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fp", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
