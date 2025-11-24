vim.g.mapleader = " "
vim.keymap.set("n", "<leader>vv", vim.cmd.Ex)



-- Center half page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- search terms stay in middle /[search] n to go next
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Keeps yanked word in copy buffer
vim.keymap.set("x", "p", [["_dP]])

-- no q button
vim.keymap.set("n", "Q", "<nop>")

-- crtnl c to esc
vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true, silent = true })

-- SYSTEM CLIP board
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
-- getting used to a keyboard
vim.keymap.set('i', '<C-v>', '<cmd>!echo dont do that<cr>')
vim.keymap.set('i', '<C-b>', '<cmd>!echo dont do that<cr>')

vim.keymap.set({ "n", "v", "i" }, "<C-n>", "<C-w>w")
vim.keymap.set("n", "<leader>qs", ":close<CR>")

vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

-- moving nvim panes
vim.api.nvim_set_keymap('n', '<C-h>', ':wincmd h<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', ':wincmd j<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ' :wincmd k<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':wincmd l<CR>', { silent = true })

-- reselected
vim.api.nvim_set_keymap('x', '<', '<gv', { noremap = true })
vim.api.nvim_set_keymap('x', '>', '>gv', { noremap = true })

-- :W is the same as :w
vim.cmd([[command! -nargs=* -complete=file W w <args>]])

-- Run latexmk for the given file

-- latexmk -pdf -pvc .\1lab.tex -f


-- db
vim.cmd("command! WhichDb echo g:db")

-- make executable
vim.api.nvim_set_keymap('n', '<leader>w', ':w | ! chmod +x %<CR><CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>o', '<C-i>', { noremap = true })

-- moving around files up and down pages
vim.api.nvim_set_keymap('n', '<leader>o', '<C-i>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-k>', ':bn<CR>', { silent = true })
-- vim.api.nvim_set_keymap('n', '<C-j>', ':bp<CR>', { silent = true })
vim.cmd('command! ResetSchema lua ResetSchema()')

-- UNMAPPING KEYMAPS THAT MESS ME Up
vim.api.nvim_del_keymap('n', '<C-W><C-D>')
vim.api.nvim_del_keymap('n', '<C-W>d')

-- Spell check with Claude
vim.keymap.set('n', '<leader>sp', function() require('desktopPJT.spell').spell_check('n') end, { desc = 'Spell check and replace word' })
vim.keymap.set('v', '<leader>sp', function() require('desktopPJT.spell').spell_check('v') end, { desc = 'Spell check and replace selection' })
