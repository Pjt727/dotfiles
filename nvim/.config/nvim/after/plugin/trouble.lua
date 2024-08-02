require('trouble').setup()
vim.keymap.set("n", "<leader>tr", function ()
    require('trouble').toggle() end)
