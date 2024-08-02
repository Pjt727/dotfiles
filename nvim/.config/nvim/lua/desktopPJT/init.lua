local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("desktopPJT.lazy")

require("desktopPJT.remap")
require("desktopPJT.set")



require('telescope').setup {
    defaults = {
        file_ignore_patterns = {
        }
    }
}
