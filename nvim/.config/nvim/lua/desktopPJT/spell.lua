local M = {}

local function replace_text(start_pos, end_pos, replacement)
  local start_line = start_pos[1]
  local start_col = start_pos[2]
  local end_line = end_pos[1]
  local end_col = end_pos[2]

  vim.api.nvim_buf_set_text(0, start_line - 1, start_col, end_line - 1, end_col, {replacement})
end

local function get_visual_selection()
  -- Exit visual mode to update '< and '>
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local start_col = start_pos[3] - 1
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  local lines = vim.api.nvim_buf_get_text(0, start_line - 1, start_col, end_line - 1, end_col, {})
  return table.concat(lines, "\n"), {start_line, start_col}, {end_line, end_col}
end

function M.spell_check(mode)
  local word, start_pos, end_pos
  local should_replace = false

  if mode == 'v' then
    -- Visual mode: get selection and replace it
    word, start_pos, end_pos = get_visual_selection()
    should_replace = true
  else
    -- Normal mode: prompt for word (default is word under cursor)
    local default_word = vim.fn.expand('<cword>')
    word = vim.fn.input("Spell check word: ", default_word)
    should_replace = false
  end

  if word == "" then
    print("No word provided")
    return
  end

  -- Call Claude CLI
  local cmd = string.format(
    'claude --model claude-haiku-4-5-20251001 -p "Provide the likely spelling for the misspelling of the word %s. IMPORTANT: only respond with the correct spelling of the word. If there are multiple possibilities, provide each on a new line." 2>/dev/null',
    vim.fn.shellescape(word)
  )

  local handle = io.popen(cmd)
  if not handle then
    print("Error: Could not execute Claude CLI")
    return
  end

  local result = handle:read("*a")
  handle:close()

  -- Trim whitespace
  result = result:gsub("^%s*(.-)%s*$", "%1")

  if result == "" then
    print("No result from Claude")
    return
  end

  -- Split by newlines
  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    if line ~= "" then
      table.insert(lines, line)
    end
  end

  if #lines > 1 then
    -- Use telescope to select
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
      prompt_title = "Spell Suggestions for '" .. word .. "'",
      finder = finders.new_table({
        results = lines
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            local choice = selection[1]
            if should_replace then
              replace_text(start_pos, end_pos, choice)
              print("Replaced with: " .. choice)
            else
              vim.fn.setreg('"', choice)
              print(choice)
            end
          end
        end)
        return true
      end,
    }):find()
  elseif result == word then
    print("'" .. word .. "' is spelled correctly")
  else
    if should_replace then
      replace_text(start_pos, end_pos, result)
      print("Replaced with: " .. result)
    else
      vim.fn.setreg('"', result)
      print(result)
    end
  end
end

return M
