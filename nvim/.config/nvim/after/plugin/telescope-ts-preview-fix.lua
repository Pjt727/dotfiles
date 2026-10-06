-- Telescope previews detect the filetype with plenary, which falls back to the file
-- extension when it has no mapping. Teach treesitter which parser those names mean.
vim.treesitter.language.register("terraform", { "tf", "tfvars", "terraform-vars" })

-- telescope.utils.has_ts_parser is `pcall(vim.treesitter.language.add, lang)`. On
-- Neovim 0.12 `add` returns `nil, err` for a missing parser instead of throwing, so the
-- pcall succeeds and the preview calls vim.treesitter.start() with a language that has
-- no parser, which asserts. Check the return value instead.
--
-- Delete this once telescope.nvim handles the 0.12 signature.
if vim.fn.has("nvim-0.12") == 1 then
    local ok, telescope_utils = pcall(require, "telescope.utils")
    if ok then
        telescope_utils.has_ts_parser = function(lang)
            local called, added = pcall(vim.treesitter.language.add, lang)
            return called and added == true
        end
    end
end
