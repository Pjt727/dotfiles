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

-- Parse aspell -a output.
-- Returns: suggestions (list), err (string|nil), status ("ok"|"miss"|"none")
local function aspell_suggestions(word)
  local cmd = string.format("printf '%%s\\n' %s | aspell -a 2>/dev/null", vim.fn.shellescape(word))
  local handle = io.popen(cmd)
  if not handle then
    return nil, "Could not execute aspell"
  end

  local result = handle:read("*a")
  handle:close()

  if not result or result == "" then
    return nil, "No result from aspell"
  end

  -- Skip the version header; look for *, &, or # response lines.
  for line in result:gmatch("[^\r\n]+") do
    local prefix = line:sub(1, 1)
    if prefix == "*" or prefix == "+" or prefix == "-" then
      return {}, nil, "ok"
    elseif prefix == "#" then
      return {}, nil, "none"
    elseif prefix == "&" then
      -- & word count offset: sug1, sug2, ...
      local suggestions_part = line:match(":%s*(.+)$")
      if not suggestions_part then
        return {}, nil, "none"
      end
      local suggestions = {}
      for sug in suggestions_part:gmatch("[^,]+") do
        sug = sug:match("^%s*(.-)%s*$")
        if sug ~= "" then
          table.insert(suggestions, sug)
        end
      end
      return suggestions, nil, "miss"
    end
  end

  return {}, nil, "none"
end

local function apply_choice(choice, should_replace, start_pos, end_pos)
  if should_replace then
    replace_text(start_pos, end_pos, choice)
    print("Replaced with: " .. choice)
  else
    vim.fn.setreg('"', choice)
    print(choice)
  end
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

  local suggestions, err, status = aspell_suggestions(word)
  if err then
    print("Error: " .. err)
    return
  end

  if status == "ok" then
    print("'" .. word .. "' is spelled correctly")
    return
  end

  if #suggestions == 0 then
    print("No suggestions for '" .. word .. "'")
    return
  end

  -- Always open the picker for misspellings (even a single suggestion)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers.new({}, {
    prompt_title = "Spell Suggestions for '" .. word .. "'",
    finder = finders.new_table({
      results = suggestions
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          apply_choice(selection[1], should_replace, start_pos, end_pos)
        end
      end)
      return true
    end,
  }):find()
end

return M
