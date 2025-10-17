-- =============================================================================
-- UI Customizations
-- =============================================================================

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	opts.title = "" -- Keep title empty as in original config
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Configure diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	virtual_text = true,
})

-- =============================================================================
-- Completion Setup (nvim-cmp)
-- =============================================================================

local cmp = require("cmp")
local luasnip = require("luasnip") -- Required for snippet functionality

-- Custom sorting function to prioritize non-dunder methods in Python
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
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sorting = {
		comparators = {
			cmp.config.compare.exact,
			cmp.config.compare.score,
			cmp.config.compare.recently_used,
			is_dunder, -- Your original custom sorter
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
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		-- Refactored to use luasnip directly, which may fix your snippet issue.
		["<C-f>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-b>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "codecompanion" },
	}),
})

-- Setup for SQL with vim-dadbod
cmp.setup.filetype({ "sql" }, {
	sources = {
		{ name = "vim-dadbod-completion" },
		{ name = "buffer" },
	},
})

-- =============================================================================
-- LSP Configuration (lspconfig)
-- =============================================================================

-- Global on_attach function to apply keymaps and settings to each LSP server
local on_attach = function(client, bufnr)
	-- This callback runs when an LSP server attaches to a buffer.
	vim.notify("LSP attached: " .. client.name, vim.log.levels.INFO, { title = "LSP" })

	local opts = { buffer = bufnr, noremap = true, silent = true }
	local keymap = vim.keymap.set

	-- Your original keymaps
	keymap("n", "gd", vim.lsp.buf.definition, opts)
	keymap("n", "<leader>vrr", vim.lsp.buf.references, opts)
	keymap("n", "K", vim.lsp.buf.hover, opts)
	keymap("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	keymap("n", "<leader>vd", vim.diagnostic.open_float, opts)
	keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
	keymap({ "n", "i" }, "<C-i>", vim.lsp.buf.signature_help, opts)

	-- Adding some common keymaps that lsp-zero might have provided
	keymap("n", "gD", vim.lsp.buf.declaration, opts)
	keymap("n", "gi", vim.lsp.buf.implementation, opts)
	keymap("n", "[d", vim.diagnostic.goto_prev, opts)
	keymap("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Get capabilities from nvim-cmp to pass to each LSP server
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- lua ls

vim.lsp.config("lua_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				disable = { "missing-parameters", "missing-fields" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.lsp.enable("lua_ls")

-- html
-- lspconfig.html.setup({
--     on_attach = on_attach,
--     capabilities = capabilities,
--     filetypes = { "html", "htmldjango", "templ" },
-- })

-- emmet

vim.lsp.config("emmet_language_server", {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "html", "htmldjango", "templ" },
})

vim.lsp.enable("emmet_language_server")

-- golang

vim.lsp.config("gopls", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.enable("gopls")

-- python

vim.lsp.config("pyright", {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		pyright = {
			plugins = {
				pycodestyle = { enabled = false },
				pylint = { enabled = false },
			},
		},
	},
})

vim.lsp.enable("pyright")

-- typst

vim.lsp.config("tinymist", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.enable("tinymist")

-- templ

vim.lsp.config("templ", {
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "templ", "lsp" },
	filetypes = { "templ" },
	root_dir = require("lspconfig.util").root_pattern("go.mod", ".git"),
	settings = {},
})

vim.lsp.enable("templ")

-- typescript

vim.lsp.config("ts_ls", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.enable("ts_ls")

-- harper

vim.lsp.config("harper_ls", {
	filetypes = { "markdown", "typst" },
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.enable("harper_ls")

-- java

-- =============================================================================
-- Language Specific Setups
-- =============================================================================

-- templ (Filetype, Treesitter, and LSP Registration)

vim.filetype.add({ extension = { templ = "templ" } })

-- Rust (rustaceanvim)
-- This plugin handles its own LSP setup. Your existing configuration is fine.
-- I've added the on_attach and capabilities to ensure it has the same keymaps.
vim.g.rustaceanvim = {
	tools = {},
	server = {
		on_attach = on_attach,
		capabilities = capabilities,
		default_settings = {
			["rust-analyzer"] = {},
		},
	},
	dap = {},
}

-- =============================================================================
-- Linting (lint.nvim)
-- =============================================================================
-- This section is independent of the LSP setup and is kept as is.
local linter = require("lint")

linter.linters_by_ft = {
	htmldjango = { "djlint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

-- =============================================================================
-- Notifications
-- =============================================================================
-- Disable some annoying messages, which are useful but I don't like

local original_notify = vim.notify

vim.notify = function(msg, level, opts)
	-- if msg == 'No information available' then
	--     return
	-- end

	-- To suppress messages containing "[lspconfig]" (e.g., autostart messages):

	if msg:match("LSP attached") then
		return
	end

	-- You can add more conditions here based on the `msg` or `opts`
	-- to filter other LSP-related notifications from nvim-notify.

	-- If the message is not suppressed, call the original notify function.
	original_notify(msg, level, opts)
end
