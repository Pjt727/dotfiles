local function should_disable_treesitter(bufnr)
    local max_lines = 5000       -- Adjust this value as needed
    local max_line_length = 1000 -- Adjust this value as needed

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count > max_lines then
        return true
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for _, line in ipairs(lines) do
        if string.len(line) > max_line_length then
            return true
        end
    end

    return false
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if should_disable_treesitter(bufnr) then
            vim.treesitter.stop(bufnr)
        end
    end,
})


require 'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "javascript", "typescript", "python", "html", "c", "lua", "vim", "vimdoc", "query",
        "gitignore", "git_config", "bash", "hyprlang", "templ", "json", "dockerfile", "yaml", "go", "sql", "http" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
    },
    autotag = {
        enable = true,
    },
    disable = function(lang, buf)
        local file_path = vim.api.nvim_buf_get_name(buf)
        -- Disable for files larger than 2MB
        if should_disable_for_size(file_path, 2048) then
            return true
        end
    end,
}
