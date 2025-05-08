local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

-- Define a global variable (you might want to define this elsewhere)
_G.my_custom_texts = {
	"This is the first text option.",
	"Another great option here.",
	"The third option is also good.",
}

local function url_picker(opts)
	opts = opts or {}
	local texts = _G.my_custom_texts

	local entries = {}
	for i, text in ipairs(texts) do
		table.insert(entries, { display = text, value = text })
	end

	pickers
		.new(opts, {
			prompt_title = "Custom Text Picker",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry.value,
						display = entry.display,
						ordinal = entry.display,
					}
				end,
			}),
			actions = {
				on_choose = function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection and selection.value then
						vim.fn.setreg("+", selection.value) -- Copy to system clipboard
						actions.close(prompt_bufnr)
					end
				end,
			},
		})
		:find()
end

return {
	url_picker = url_picker,
}
