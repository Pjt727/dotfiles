local defaults_keymaps = {
	edit_with_instructions = {
		diff = false,
		keymaps = {
			close = "<C-x>",
			accept = "<C-y>",
			toggle_diff = "<C-d>",
			toggle_settings = "<C-o>",
			toggle_help = "<C-h>",
			cycle_windows = "<Tab>",
			use_output_as_input = "<C-i>",
		},
	},
	chat = {
		keymaps = {
			close = "<C-x>",
			yank_last = "<C-y>",
			yank_last_code = "<C-k>",
			scroll_up = "<C-u>",
			scroll_down = "<C-d>",
			new_session = "<C-n>",
			cycle_windows = "<Tab>",
			cycle_modes = "<C-f>",
			next_message = "<C-j>",
			prev_message = "<C-k>",
			select_session = "<Space>",
			rename_session = "r",
			delete_session = "d",
			draft_message = "<C-r>",
			edit_message = "e",
			delete_message = "d",
			toggle_settings = "<C-o>",
			toggle_sessions = "<C-p>",
			toggle_help = "<C-h>",
			toggle_message_role = "<C-r>",
			toggle_system_role_open = "<C-s>",
			stop_generating = "<C-z>",
		},
	},
	popup_window = {
		border = {
			highlight = "FloatBorder",
			style = "rounded",
			text = {
				top = " Ask me it! ",
			},
		},
	},
}

require("chatgpt").setup(defaults_keymaps)
vim.keymap.set("n", "<Leader>ch", "<CMD>ChatGPT<CR>", { desc = "Open Chat GTP" })
