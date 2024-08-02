-- trying to get folding range weird html error thing fixed
-- I still dont know why it still happens but only sometimes
local lsp = require('lsp-zero')
require("mason").setup()
local mason_config = require("mason-lspconfig")
mason_config.setup {
    ensure_installed = { "lua_ls", "pyright", "rust_analyzer", "html", "tsserver", "texlab" },
    handlers = {
        lsp.default_setup,
        lua_ls = function()
            local lua_opts = lsp.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
        html = function()
            require('lspconfig').html.setup({
                filetypes = { "html", "htmldjango" },
            })
        end,
        tsserver = function()
            require('lspconfig').tsserver.setup({
                filetypes = { "htmldjango", "javascript", "html", "typescript" },
            })
        end,
    }
}

-- lsp.format_on_save({
--     format_opts = {
--         async = false,
--         timeout_ms = 10000,
--     },
--     servers = {
--         ['pyright'] = { 'python' },
--         ['rust_analyzer'] = { 'rust' },
--     }
-- })

local linter = require('lint')

linter.linters_by_ft = {
    htmldjango = { 'djlint', },
}

linter.get_running()


lsp.preset("recommended")

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- WHY CANT I GET LUASNIP TO WORK???
        { name = 'buffer' },
        { name = 'path' },
    })
})
-- setup vim-dadbod

cmp.setup.filetype({ "sql" }, {
    sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" }
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    lsp.default_keymaps({ buffer = bufnr })
    -- love these two
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)

    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    -- REMEMBER THIS
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<C-i>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("i", "<C-i>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- (Optional) Configure lua language server for neovim
-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
