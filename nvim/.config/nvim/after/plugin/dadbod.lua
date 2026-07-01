vim.api.nvim_set_keymap('n', '<leader>db', ':DBUIToggle<CR>', { noremap = true, silent = true })


-- vim.api.nvim_set_keymap('x', 'ic', ':<C-u>lua SelectSqlTextObject()<CR>', { noremap = true, silent = true })
--
--
-- -- vim.api.nvim_set_keymap('n', '<leader>q', ':DB g:db v:require("dadbod").op_exec()', { expr = true })
-- vim.keymap.set('n', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })
-- vim.keymap.set('x', '<leader>rs', function() return vim.fn['db#op_exec']() end, { expr = true })


-- Setup for SQL with vim-dadbod
-- local cmp = require('cmp')
-- -- local ts_utils = require('nvim-treesitter.ts_utils')
--
-- cmp.setup.filetype({ "sql" }, {
--     sources = {
--         { name = "vim-dadbod-completion" },
--         { name = "buffer" },
--     },
-- })

-- Helper function to execute DB query
local function execute_db_query(query)
    query = string.gsub(query, "\n", " ")
    vim.cmd("silent! DB " .. query)
end

-- Parse parameters from query
local function parse_parameters(query)
    local params = {}
    local seen = {}

    -- Match patterns: $1::int, $1, :foo_bar::int, $foo_bar
    -- Pattern 1: $name::type or :name::type (with type annotation)
    -- Match word chars (including underscore) followed by :: and type
    for match in string.gmatch(query, "([$:][%w_]+::[%w_]+)") do
        if not seen[match] then
            local prefix, name, type_spec = string.match(match, "^([$:])([%w_]+)::([%w_]+)$")
            if prefix and name and type_spec then
                table.insert(params, {
                    full = match,
                    name = name,
                    type = type_spec,
                    prefix = prefix
                })
                seen[match] = true
            end
        end
    end

    -- Pattern 2: $name or :name (without type)
    -- Must not be preceded by : (to avoid matching :text from ::text)
    -- Must not be followed by :: (which would indicate a typed parameter)
    local i = 1
    while i <= #query do
        local start, finish, prefix, name = string.find(query, "([$:])([%w_]+)", i)
        if not start then break end

        local full_match = prefix .. name
        local prev_char = start > 1 and string.sub(query, start - 1, start - 1) or ""
        local next_chars = string.sub(query, finish + 1, finish + 2)

        -- Only match if:
        -- 1. NOT preceded by : (to avoid :text from ::text)
        -- 2. NOT followed by :: (which would indicate a typed parameter)
        -- 3. Not already seen
        if prev_char ~= ":" and next_chars ~= "::" and not seen[full_match] then
            table.insert(params, {
                full = full_match,
                name = name,
                type = nil,
                prefix = prefix
            })
            seen[full_match] = true
        end

        i = finish + 1
    end

    return params
end

-- Get default value for a type
local function get_default_value(type_spec)
    if not type_spec then
        return "''"
    end

    local lower_type = string.lower(type_spec)
    if string.match(lower_type, "int") or string.match(lower_type, "numeric") or string.match(lower_type, "decimal") then
        return "1"
    elseif string.match(lower_type, "text") or string.match(lower_type, "varchar") or string.match(lower_type, "char") then
        return "''"
    elseif string.match(lower_type, "timestamp") or string.match(lower_type, "date") or string.match(lower_type, "time") then
        return "'1970-01-01 00:00:00'"
    elseif string.match(lower_type, "bool") then
        return "false"
    else
        return "''"
    end
end

-- Process parameter replacement with special values
local function process_replacement(value, type_spec, full_param)
    if value == 'n' then
        return 'NULL'
    elseif value == 'd' then
        return get_default_value(type_spec)
    elseif not type_spec then
        -- No type specified, replace entire parameter with user input
        return value
    else
        -- Type specified, quote if needed
        local lower_type = string.lower(type_spec)
        if string.match(lower_type, "int") or string.match(lower_type, "numeric") or string.match(lower_type, "decimal") or string.match(lower_type, "bool") then
            return value
        else
            return "'" .. value .. "'"
        end
    end
end

-- Interactive database parameter replacement and execution
vim.keymap.set('x', '<leader>rs', function()
    -- Exit visual mode to update the '< and '> marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    -- Get visual selection
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

    -- Adjust for visual selection bounds
    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
    elseif #lines > 1 then
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
    end

    local query = table.concat(lines, "\n")
    print(query)
    local params = parse_parameters(query)

    -- If no parameters found, execute directly
    if #params == 0 then
        execute_db_query(query)
        return
    end

    -- Process parameters one by one
    local final_query = query
    local param_index = 1

    local function prompt_next_param()
        if param_index > #params then
            -- All parameters processed, execute query
            execute_db_query(final_query)
            return
        end

        local param = params[param_index]
        local prompt_text = string.format('%s%s (type: %s, n=NULL, d=default): ',
            param.prefix,
            param.name,
            param.type or 'any')

        vim.ui.input({
            prompt = prompt_text
        }, function(input)
            if input == nil then
                -- User cancelled
                return
            end

            -- Process the replacement
            local replacement = process_replacement(input, param.type, param.full)

            -- Replace in query (escape special pattern characters)
            local pattern = string.gsub(param.full, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
            final_query = string.gsub(final_query, pattern, replacement)

            -- Move to next parameter
            param_index = param_index + 1
            prompt_next_param()
        end)
    end

    -- Start prompting
    prompt_next_param()
end, {
    noremap = true,
    silent = true,
    desc = 'Execute DB query with interactive parameter replacement'
})
