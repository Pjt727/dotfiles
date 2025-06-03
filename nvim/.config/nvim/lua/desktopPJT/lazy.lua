vim.g.mapleader = " " -- ensure that mapleader is set for other pluginslazy
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
--
local plugins = {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.x",
        -- or                            , branch = '0.1.x',
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    { "rose-pine/neovim",                     as = "rose-pine" },
    -- ufo nvim for folding
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
    },

    -- run TSUpdate?
    "nvim-treesitter/nvim-treesitter",
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    "mbbill/undotree",
    "tpope/vim-fugitive",
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            --- Uncomment these if you want to manage LSP servers from neovim
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- LSP Support
            { "neovim/nvim-lspconfig" },
            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "L3MON4D3/LuaSnip" },
        },
    },
    -- Better dianogistic window
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            {
                "<leader>tr",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
        },
    },
    "mfussenegger/nvim-lint",
    -- it flickers lualine
    "jiangmiao/auto-pairs",
    "windwp/nvim-ts-autotag",
    {
        "filipdutescu/renamer.nvim",
        event = "VeryLazy",
        branch = "master",
        dependencies = { { "nvim-lua/plenary.nvim" } },
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end,
    },
    {
        "olimorris/codecompanion.nvim",
        config = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "stevearc/oil.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    -- lua line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    "ThePrimeagen/vim-be-good",
    {
        "stevearc/conform.nvim",
        opts = {},
    },

    -- sql stuff
    {
        "kristijanhusak/vim-dadbod-ui",
        event = "VeryLazy",
        dependencies = {
            { "tpope/vim-dadbod",                     lazy = true },
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },

    -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
    {
        "numToStr/Comment.nvim",
        opts = {
            -- add any options here
        },
        lazy = false,
    },
    {
        "Vonr/align.nvim",
        branch = "v2",
        lazy = true,
        init = function()
            vim.keymap.set("x", "aw", function()
                require("align").align_to_string({
                    preview = true,
                    regex = false,
                })
            end, NS)
            vim.keymap.set("x", "ar", function()
                require("align").align_to_string({
                    preview = true,
                    regex = true,
                })
            end, NS)
        end,
    },
    { "nvim-telescope/telescope-symbols.nvim" },
    { "mistweaverco/kulala.nvim" },
}

local opts = {}

require("lazy").setup(plugins, opts)
