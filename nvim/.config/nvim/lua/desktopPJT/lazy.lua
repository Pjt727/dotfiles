vim.g.mapleader = " " -- ensure that mapleader is set for other pluginslazylazy
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
--
local plugins = {
    -- Packer can manage itself
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
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
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
        "HakonHarnes/img-clip.nvim",
        event = "BufEnter",
        opts = {
            -- add options here
            -- or leave it empty to use the default settings
        },
        keys = {
            -- suggested keymap
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste clipboard image" },
        },
    },
    {
        "olimorris/codecompanion.nvim",
        config = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "ravitemer/codecompanion-history.nvim",
        },
    },
    -- Might be useful if I want to lean into ai workflows
    -- {
    --     "ravitemer/mcphub.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    --     },
    --     -- uncomment the following line to load hub lazily
    --     --cmd = "MCPHub",  -- lazy load
    --     build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    --     -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    --     -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    --     config = function()
    --         require("mcphub").setup()
    --     end,
    -- },
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
        "kawre/leetcode.nvim",
        build = ":TSUpdate html",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim", -- required by telescope
            "MunifTanjim/nui.nvim",

            -- optional
            "nvim-treesitter/nvim-treesitter",
            "rcarriga/nvim-notify",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- configuration goes here
        },
    },
    {
        "leath-dub/snipe.nvim",
        keys = {
            {
                "<leader>s",
                function()
                    require("snipe").open_buffer_menu()
                end,
                desc = "Open Snipe buffer menu",
            },
        },
        opts = {},
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
    {
        "oysandvik94/curl.nvim",
        cmd = { "CurlOpen" },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = true,
    },
    { "mistweaverco/kulala.nvim" },
    { "barreiroleo/ltex-extra.nvim" },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    -- some mini plugins maybe I will add the whole mini ecosystem
    { "echasnovski/mini.move", version = "*" },
    { "echasnovski/mini.diff", version = "*" },

    -- rust helpers
    {
        "mrcjkb/rustaceanvim",
        version = "^6", -- Recommended
        lazy = false,   -- This plugin is already lazy
    },
    {
        "hat0uma/csvview.nvim",
        ---@module "csvview"
        ---@type CsvView.Options
        opts = {
            parser = { comments = { "#", "//" } },
            keymaps = {
                -- Text objects for selecting fields
                textobject_field_inner = { "if", mode = { "o", "x" } },
                textobject_field_outer = { "af", mode = { "o", "x" } },
                -- Excel-like navigation:
                -- Use <Tab> and <S-Tab> to move horizontally between fields.
                -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
                -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
                jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
                jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
                jump_next_row = { "<Enter>", mode = { "n", "v" } },
                jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
            },
        },
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    },
    -- marco helper
    {
        "chrisgrieser/nvim-recorder",
        dependencies = "rcarriga/nvim-notify", -- optional
        opts = {},                             -- required even with default settings, since it calls `setup()`
    },
}

local opts = {}

require("lazy").setup(plugins, opts)
