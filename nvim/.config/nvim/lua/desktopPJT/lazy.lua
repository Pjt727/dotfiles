vim.g.mapleader = " " -- ensure that mapleader is set for other pluginslazy
-- This file can be loaded by calling `lua require('plugins')` from your init.vim
--
local plugins = {
	-- Packer can manage itself
	"wbthomason/packer.nvim",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.x",
		-- or                            , branch = '0.1.x',
		dependencies = { { "nvim-lua/plenary.nvim" } },
	},
	{ "rose-pine/neovim", as = "rose-pine" },
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
	-- preview markdown
	-- {
	--     "iamcco/markdown-preview.nvim",
	--     event = "VeryLazy",
	--     cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	--     ft = { "markdown" },
	--     build = function() vim.fn["mkdp#util#install"]() end,
	-- },
	-- copy and paste images
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
	--CHAT GPT
	{
		"jackMort/ChatGPT.nvim",
		cmd = "ChatGPT",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
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
	-- which key IDK why but my C-c key is funky
	--
	-- {
	--     "folke/which-key.nvim",
	--     event = "VeryLazy",
	--     init = function()
	--         vim.o.timeout = true
	--         vim.o.timeoutlen = 300
	--     end,
	--     opts = {
	--         triggers_blacklist = {
	--             -- list of mode / prefixes that should never be hooked by WhichKey
	--             -- this is mostly relevant for keymaps that start with a native binding
	--             i = { "j", "k" },
	--             n = {"y", "d", "c" },
	--             v = { "j", "k" },
	--         },
	--         -- your configuration comes here
	--         -- or leave it empty to use the default settings
	--         -- refer to the configuration section below
	--     }
	-- },
	-- lazy.nvim
	-- {
	--   "folke/noice.nvim",
	--   event = "VeryLazy",
	--   opts = {
	--     -- add any options here
	--   },
	--   dependencies = {
	--     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
	--     "MunifTanjim/nui.nvim",
	--     }
	-- },
	-- My select plugin :D
	"Pjt727/nvim-myselect",

	"ThePrimeagen/vim-be-good",
	-- all attempts to get code pics :/
	--
	-- { "mistricky/codesnap.nvim", build = "make" },
	-- {
	--   "ellisonleao/carbon-now.nvim",
	--   lazy = true,
	--   cmd = "CarbonNow",
	--   ---@param opts cn.ConfigSchema
	--   opts = { [[ your custom config here ]] }
	-- },
	-- {
	--     "michaelrommel/nvim-silicon",
	--     lazy = true,
	--     cmd = "Silicon",
	--     config = function()
	--         require("silicon").setup({
	--             -- Configuration here, or leave empty to use defaults
	--             font = "VictorMono NF=34;Noto Emoji=34"
	--         })
	--     end
	-- },
	{
		"stevearc/conform.nvim",
		opts = {},
	},
	--  lua rocks does not work missing curl
	-- {
	--     "vhyrro/luarocks.nvim",
	--     priority = 1000,
	--     config = true,
	--     opts = {
	--         rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" }
	--     }
	-- },
	-- rest curl apparently not working correctly
	-- {
	--     "rest-nvim/rest.nvim",
	--     ft = "http",
	--     config = function()
	--         require("rest-nvim").setup()
	--     end,
	-- },
	--
	--

	-- sql stuff
	{
		"kristijanhusak/vim-dadbod-ui",
		event = "VeryLazy",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
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
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			-- these are examples, not defaults. Please see the readme
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
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
	{ "jsborjesson/vim-uppercase-sql" },
	{ "mistweaverco/kulala.nvim" },
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{ "barreiroleo/ltex-extra.nvim" },
}

local opts = {}

require("lazy").setup(plugins, opts)
