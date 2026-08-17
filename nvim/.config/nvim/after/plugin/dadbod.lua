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

-- Track active query job for cancellation
local active_query_job = nil
local query_output_buf = nil

-- Helper function to execute DB query asynchronously with cancellation support
local function execute_db_query(query)
    query = string.gsub(query, "\n", " ")

    local db = vim.g.db
    if not db or db == "" then
        vim.notify("No database connection set (g:db is empty)", vim.log.levels.ERROR)
        return
    end

    -- Use vim-dadbod's url parsing to get the adapter and build the command
    -- Falls back to synchronous :DB if we can't parse the URL
    local ok, cmd_parts = pcall(function()
        local parsed = vim.fn['db#url#parse'](db)
        local adapter = parsed.scheme or parsed.adapter
        if not adapter then return nil end
        -- Let dadbod build the actual command for us
        return vim.fn['db#adapter#dispatch'](db, 'interactive')
    end)

    if not ok or not cmd_parts or cmd_parts == "" then
        -- Fallback to synchronous execution
        vim.cmd("silent! DB " .. query)
        return
    end

    -- db#adapter#dispatch may return a list; join into a shell command string
    if type(cmd_parts) == "table" then
        local escaped = {}
        for _, part in ipairs(cmd_parts) do
            table.insert(escaped, vim.fn.shellescape(part))
        end
        cmd_parts = table.concat(escaped, " ")
    end

    -- Find or create the output buffer
    local buf = query_output_buf
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(false, true)
        query_output_buf = buf
    end

    -- Set up the output buffer
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_name(buf, '[DB Query Result]')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "-- Running query..." })

    -- Show the buffer in a split (reuse existing window if open)
    local win = nil
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == buf then
            win = w
            break
        end
    end
    if not win then
        local height = math.floor(vim.o.lines / 3)
        vim.cmd("botright " .. height .. "split")
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
    end

    -- Cancel any existing query
    if active_query_job then
        pcall(vim.fn.jobstop, active_query_job)
        active_query_job = nil
    end

    local output_lines = {}

    -- Build command: pipe query into the db adapter's interactive command
    local shell_cmd = string.format("echo %s | %s", vim.fn.shellescape(query), cmd_parts)

    active_query_job = vim.fn.jobstart({ "sh", "-c", shell_cmd }, {
        stdout_buffered = false,
        stderr_buffered = false,
        on_stdout = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
                    end
                end)
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, "ERR: " .. line)
                    end
                end
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
                    end
                end)
            end
        end,
        on_exit = function(_, exit_code, _)
            vim.schedule(function()
                if exit_code ~= 0 and #output_lines == 0 then
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_set_lines(buf, 0, -1, false,
                            { "-- Query cancelled or failed (exit code: " .. exit_code .. ")" })
                    end
                end
                active_query_job = nil
            end)
        end,
    })

    -- Set up Ctrl+C mapping in the output buffer to cancel the query
    vim.api.nvim_buf_set_keymap(buf, 'n', '<C-c>', '', {
        noremap = true,
        silent = true,
        callback = function()
            if active_query_job then
                vim.fn.jobstop(active_query_job)
                active_query_job = nil
                vim.notify("Query cancelled", vim.log.levels.WARN)
            end
        end,
        desc = "Cancel running DB query",
    })
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
