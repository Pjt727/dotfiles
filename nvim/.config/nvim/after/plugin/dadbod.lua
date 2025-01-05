vim.api.nvim_set_keymap('n', '<leader>db', ':DBUIToggle<CR>', { noremap = true, silent = true })





function SelectSqlTextObject()
    local start = vim.fn.search('[/select/][/delete/][/insert/]')
    local finish = vim.fn.search('[;]', "W")
    vim.cmd('normal! V' .. start .. 'G' .. finish .. 'G')
end

vim.api.nvim_set_keymap('x', 'ic', ':<C-u>lua SelectSqlTextObject()<CR>', { noremap = true, silent = true })


-- vim.api.nvim_set_keymap('n', '<leader>q', ':DB g:db v:require("dadbod").op_exec()', { expr = true })
vim.keymap.set('n', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })
vim.keymap.set('x', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })

vim.keymap.set('n', '<leader>so', function()
    -- Find the start of the SQL statement
    local start = vim.fn.search('[/select/][/delete/][/insert/]', 'b')
    if start == 0 then
        print("No SQL statement found")
        return
    end

    -- Find the end of the SQL statement
    local finish = vim.fn.search(';', 'W')
    if finish == 0 then
        print("No ending semicolon found")
        return
    end

    -- Select the SQL statement
    vim.cmd('normal! V' .. start .. 'G' .. finish .. 'G')
end, { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'is', ':<C-U>exec "normal! `<V`>y:call SqlExecute()<CR>"', { noremap = true, silent = true })

--[[
;
dd
SelEcT
;
]]
