vim.api.nvim_set_keymap('n', '<leader>db', ':DBUIToggle<CR>', { noremap = true, silent = true })


vim.api.nvim_set_keymap('x', 'ic', ':<C-u>lua SelectSqlTextObject()<CR>', { noremap = true, silent = true })


-- vim.api.nvim_set_keymap('n', '<leader>q', ':DB g:db v:require("dadbod").op_exec()', { expr = true })
vim.keymap.set('n', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })
vim.keymap.set('x', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })


-- Setup for SQL with vim-dadbod
local cmp = require('cmp')
-- local ts_utils = require('nvim-treesitter.ts_utils')

cmp.setup.filetype({ "sql" }, {
    sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" },
    },
})
