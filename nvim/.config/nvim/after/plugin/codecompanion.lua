-- require("codecompanion.completion").slash_commands()
--
-- local fetch_item = nil
-- for _, s in require("codecompanion.completion").slash_commands() do
-- 	if s.config.label == "/fetch" then
-- 		fetch_item = s
-- 		break
-- 	end
-- end
-- vim.api.nvim_create_user_command("InsertUrl", function()
-- 	local chat = require("codecompanion").buf_get_chat(vim.api.get_current_buf())
-- 	require("codecompanion.completion").slash_commands_execute(fetch_item, chat)
-- end, {})
local constants = {
	LLM_ROLE = "llm",
	USER_ROLE = "user",
	SYSTEM_ROLE = "system",
}

local fmt = string.format

require("codecompanion").setup({
	opts = {
		log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
	},
	strategies = {
		inline = {
			adapter = "gemini",
			keymaps = {
				accept_change = {
					modes = { n = "ga" },
					description = "Accept the suggested change",
				},
				reject_change = {
					modes = { n = "gr" },
					description = "Reject the suggested change",
				},
			},
		},
		chat = {
			adapter = "gemini",
			keymaps = {
				close = {
					modes = { n = "<C-m>", i = "<C-m>" },
				},
				-- Add further custom keymaps here
			},
			slash_commands = {
				["file"] = {
					opts = {
						provider = "telescope", -- default|telescope|mini_pick|fzf_lua
					},
				},
				["buffer"] = {
					opts = {
						provider = "telescope", -- default|telescope|mini_pick|fzf_lua
					},
				},
			},
		},
	},
	adapters = {
		http = {
			llama3 = function()
				return require("codecompanion.adapters").extend("gemini", {
					name = "gem",
					schema = {
						model = {
							default = "gemini-2.5-pro",
						},
						-- num_ctx = {
						--   default = 16384,
						-- },
						-- num_predict = {
						--   default = -1,
						-- },
					},
				})
			end,
		},
	},
	display = {
		diff = {
			enabled = true,
			close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
			layout = "vertical", -- vertical|horizontal split for default provider
			opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
			provider = "default", -- default|mini_diff
		},
		chat = {
			-- Change the default icons
			icons = {
				pinned_buffer = " ",
				watched_buffer = "👀 ",
			},

			-- Alter the sizing of the debug window
			debug_window = {
				---@return number|fun(): number
				width = vim.o.columns - 5,
				---@return number|fun(): number
				height = vim.o.lines - 2,
			},

			-- Options to customize the UI of the chat buffer
			window = {
				layout = "float", -- float|vertical|horizontal|buffer
				position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
				border = "single",
				height = 0.8,
				width = 0.9,
				relative = "editor",
				full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
				opts = {
					breakindent = true,
					cursorcolumn = false,
					cursorline = false,
					foldcolumn = "0",
					linebreak = true,
					list = false,
					numberwidth = 1,
					signcolumn = "no",
					spell = false,
					wrap = true,
				},
			},

			---Customize how tokens are displayed
			---@param tokens number
			---@param adapter CodeCompanion.Adapter
			---@return string
			token_count = function(tokens, adapter)
				return " (" .. tokens .. " tokens)"
			end,
		},
		action_palette = {
			provider = "telescope",
		},
	},
	extensions = {
		-- mcphub = {
		--     callback = "mcphub.extensions.codecompanion",
		--     opts = {
		--         show_result_in_chat = true, -- Show mcp tool results in chat
		--         make_vars = true,           -- Convert resources to #variables
		--         make_slash_commands = true, -- Add prompts as /slash commands
		--     },
		-- },
	},

	prompt_library = {
		["Replace code"] = {
			strategy = "inline",
			description = "Replace the selected code",
			opts = {
				index = 8,
				is_default = true,
				is_slash_cmd = false,
				modes = { "v" },
				short_name = "replace",
				auto_submit = true,
				placement = "new",
				user_prompt = true,
			},
			prompts = {
				{
					role = constants.SYSTEM_ROLE,
					content = table.concat(
						vim.fn.readfile(
							vim.fs.joinpath(
								vim.fn.stdpath("config"),
								"after",
								"plugin",
								"codecompanion-prompts",
								"replace-system-prompt.md"
							)
						),
						"\n"
					),
				},
				{
					role = constants.USER_ROLE,
					content = function(context)
						local code =
							require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
						return fmt(
							[[Use the following code as a basis to correct as needed use a valid correct to replace this code:

```%s
%s
```
]],
							context.filetype,
							code
						)
					end,
				},
			},
		},
	},
})

vim.keymap.set("n", "<Leader>h", "<CMD>CodeCompanionChat Toggle<CR>", { desc = "Open Chat GTP" })
vim.keymap.set("v", "<Leader>h", "<cmd>CodeCompanionChat Toggle<CR>", { noremap = true, silent = true })
