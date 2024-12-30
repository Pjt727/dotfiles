vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cmdheight = 0

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- sql C-c
vim.g.ftplugin_sql_omni_key = nil
vim.g.omni_sql_no_default_maps = 1

-- set up local nvim config for repors
vim.o.exrc = true
vim.o.secure = true

-- http files
vim.filetype.add({
  extension = {
    ['http'] = 'http',
  },
})
