vim.o.foldcolumn = '0' -- '0' is not bad '1' will give column to show fold area
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

-- Hack that seems to prvent foldingranges error from not happening
local filetypes = { 
    html = { 'treesitter', 'indent' },
    htmldjango = { 'treesitter', 'indent' },
}
require('ufo').setup({
    provider_selector = function (bufnr, filetype, buftype)

        return filetypes[filetype] or { 'lsp', 'indent' }
    end
})
