vim.g.mapleader = " "
vim.keymap.set("n", "<leader>vv", vim.cmd.Ex)


-- moving selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


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
vim.keymap.set('i', '<C-v>', '<Esc>"+p')

vim.keymap.set("n", "<Leader>s", ":vsplit<CR>")

vim.keymap.set({ "n", "v", "i" }, "<C-n>", "<C-w>w")
vim.keymap.set("n", "<leader>qs", ":close<CR>")

vim.api.nvim_set_keymap('i', '<F2>', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>rn', '<cmd>lua require("renamer").rename()<cr>', { noremap = true, silent = true })

-- moving nvim panes
vim.api.nvim_set_keymap('n', '<C-h>', ':wincmd h<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', ':wincmd j<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':wincmd k<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':wincmd l<CR>', { silent = true })

-- reselected
vim.api.nvim_set_keymap('x', '<', '<gv', { noremap = true })
vim.api.nvim_set_keymap('x', '>', '>gv', { noremap = true })

-- :W is the same as :w
vim.cmd([[command! -nargs=* -complete=file W w <args>]])

-- Run latexmk for the given file

-- latexmk -pdf -pvc .\1lab.tex -f


-- WINDOWS TERMINAL SPECIFIC running a latex document
-- vim.api.nvim_set_keymap('n', '<leader>rl', [[:!wt -d "%:p" --title="Live Latex" powershell.exe -Command "latexmk -pdf -synctex=1 -pvc % "<cr>]], { noremap = true, silent = true })
-- if you try to do forward and backward search make sure
-- synctex=1
vim.api.nvim_set_keymap('n', '<leader>rl',
    [[:!wt -d "%:p:h:h" --title="Live Latex" powershell.exe -Command "latexmk -pdf -output-directory='%:h' -pvc '%:p' "<cr>]],
    { noremap = true, silent = true })


-- PSQL command just for my database class to reset the CAP database
function ResetSchema()
    local cmd = 'psql -d BANNER -U postgres -f BANNER-schema.sql'
    vim.cmd('!' .. cmd)
    print("Reset!")
end

-- make executable
vim.api.nvim_set_keymap('n', '<leader>w', ':w | ! chmod +x %<CR><CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>o', '<C-i>', { noremap = true })

-- moving around files up and down pages
vim.api.nvim_set_keymap('n', '<leader>o', '<C-i>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-k>', ':bn<CR>', { silent = true })
-- vim.api.nvim_set_keymap('n', '<C-j>', ':bp<CR>', { silent = true })
vim.cmd('command! ResetSchema lua ResetSchema()')

-- command to run current file and output context to a md file
-- only redirects when the psql command is successful
function RunSQL()
    vim.api.nvim_command("w")
    local currentFilePath = vim.fn.expand('%:p')
    local currentDir = vim.fn.expand('%:p:h')
    local fileName = vim.fn.expand('%:t:r')
    local newFileName = currentDir .. '\\' .. fileName .. '.txt'
    local cmd = 'psql -d BANNER -U postgres -f ' .. currentFilePath .. ' -o ' .. newFileName
    vim.cmd('!' .. cmd)
    local f = io.open(newFileName, "r")
    local size = f:seek("end")
    if not (size == 0) then
        vim.cmd('view ' .. newFileName)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
    end
end

-- command to run current file and output context to a md file
-- only redirects when the psql command is successful
function RunSQLLoud()
    vim.api.nvim_command("w")
    local currentFilePath = vim.fn.expand('%:p')
    local currentDir = vim.fn.expand('%:p:h')
    local fileName = vim.fn.expand('%:t:r')
    local newFileName = currentDir .. '\\' .. fileName .. '.txt'
    local cmd = 'psql -d BANNER -U postgres -f ' .. currentFilePath .. ' -o ' .. newFileName
    vim.cmd(cmd)
    local f = io.open(newFileName, "r")
    local size = f:seek("end")
    if not (size == 0) then
        vim.cmd('view ' .. newFileName)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", true)
    end
end

vim.cmd('command! RunSqlLoud lua RunSQLLoud()')

function RunSqlCsv()
    local currentFilePath = vim.fn.expand('%:p')
    local currentDir = vim.fn.expand('%:p:h')
    local fileName = vim.fn.expand('%:t:r')
    local newFileName = currentDir .. '\\' .. fileName .. '.csv'
    vim.fn.writefile({}, newFileName)
    vim.cmd('view ' .. newFileName)
    local cmd = 'psql -d BANNER -U postgres --csv -f ' .. currentFilePath .. ' -o ' .. newFileName
    vim.cmd('!' .. cmd)
end

vim.cmd('command! RunSql lua RunSQL()')

vim.api.nvim_set_keymap('n', '<leader>rs', ':lua RunSQL()<CR>', { noremap = true })
vim.cmd('command! RunSqlCsv lua RunSqlCsv()')
