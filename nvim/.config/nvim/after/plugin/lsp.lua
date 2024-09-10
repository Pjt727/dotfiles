-- trying to get folding range weird html error thing fixed
-- I still dont know why it still happens but only sometimes
local lsp = require("lsp-zero")
require("mason").setup()
local mason_config = require("mason-lspconfig")
mason_config.setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "html", "tsserver", "htmx" },
	handlers = {
		lsp.default_setup,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
		end,
		html = function()
			require("lspconfig").html.setup({
				filetypes = { "html", "htmldjango" },
			})
		end,
		htmx = function()
			require("lspconfig").html.setup({
				filetypes = { "html", "htmldjango" },
			})
		end,
		tsserver = function()
			require("lspconfig").tsserver.setup({
				filetypes = { "htmldjango", "javascript", "html", "typescript" },
			})
		end,
		pylsp = function()
			require("lspconfig").pylsp.setup({
				settings = {
					pylsp = {

						plugins = {
							pycodestyle = { enabled = false },
							pylint = { enabled = false }, -- or set to true if you want to keep pylint
						},
					},
				},
			})
		end,
	},
})

local linter = require("lint")

linter.linters_by_ft = {
	htmldjango = { "djlint" },
	-- markdown = { 'vale', },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		-- try_lint without arguments runs the linters defined in `linters_by_ft`
		-- for the current filetype
		require("lint").try_lint()
	end,
})

-- linter.get_running()

lsp.preset("recommended")

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

local function is_dunder(entry1, entry2)
	local _, entry1_under = entry1.completion_item.label:find("^_+")
	local _, entry2_under = entry2.completion_item.label:find("^_+")
	entry1_under = entry1_under or 0
	entry2_under = entry2_under or 0
	if entry1_under > entry2_under then
		return false
	elseif entry1_under < entry2_under then
		return true
	end
end

cmp.setup({
	sorting = {
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			is_dunder,
			cmp.config.compare.kind,
			cmp.config.compare.sort_text,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-f>"] = cmp_action.luasnip_jump_forward(),
		["<C-b>"] = cmp_action.luasnip_jump_backward(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, -- WHY CANT I GET LUASNIP TO WORK???
		{ name = "buffer" },
		{ name = "path" },
	}),
})
-- setup vim-dadbod

cmp.setup.filetype({ "sql" }, {
	sources = {
		{ name = "vim-dadbod-completion" },
		{ name = "buffer" },
	},
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }
	lsp.default_keymaps({ buffer = bufnr })
	-- love these two
	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)

	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	-- REMEMBER THIS
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>ca", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap.set("n", "<leader>rn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("n", "<C-i>", function()
		vim.lsp.buf.signature_help()
	end, opts)
	vim.keymap.set("i", "<C-i>", function()
		vim.lsp.buf.signature_help()
	end, opts)
end)

-- (Optional) Configure lua language server for neovim
-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
})
