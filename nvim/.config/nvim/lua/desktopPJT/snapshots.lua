local M = {}

local defaults = {
    retention_days = 10,
    storage_dir = vim.fn.stdpath("data") .. "/config-snapshots",
    keymaps = {
        cut = "<leader>vc",
        load = "<leader>vl",
    },
}

local state

local function trim(value)
    return (value or ""):gsub("%s+$", "")
end

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Config snapshots" })
end

local function new_id(prefix)
    return string.format(
        "%s-%s-%d-%x",
        prefix,
        os.date("%Y%m%d-%H%M%S"),
        vim.fn.getpid(),
        vim.uv.hrtime() % 0xffffff
    )
end

local function index_path(group)
    return state.index_dir .. "/" .. (group or "_store")
end

local function run(command, options)
    options = options or {}
    local result = vim.system(command, {
        cwd = options.cwd,
        env = options.env,
        text = true,
    }):wait()

    if result.code ~= 0 and not options.allow_failure then
        error(trim(result.stderr) ~= "" and trim(result.stderr) or table.concat(command, " "))
    end

    return trim(result.stdout), result.code
end

local function git(arguments, options)
    options = options or {}
    local command = {
        "git",
        "-c",
        "core.excludesFile=/dev/null",
        "--git-dir=" .. state.repo,
        "--work-tree=" .. state.config_root,
    }
    vim.list_extend(command, arguments)

    local env = options.env or {}
    env.GIT_INDEX_FILE = options.index or index_path(options.group or state.group)

    return run(command, {
        cwd = state.config_root,
        env = env,
        allow_failure = options.allow_failure,
    })
end

local function ref_exists(ref)
    local _, code = git({ "rev-parse", "--verify", "--quiet", ref }, { allow_failure = true })
    return code == 0
end

local function group_ref(group)
    return "refs/config-snapshot-groups/" .. group
end

local function snapshot_ref(snapshot)
    return "refs/config-snapshots/" .. snapshot
end

local function group_head(group)
    return git({ "rev-parse", "--verify", group_ref(group) }, { group = group })
end

local function initialize_store()
    vim.fn.mkdir(state.storage_dir, "p")
    vim.fn.mkdir(state.index_dir, "p")

    if vim.uv.fs_stat(state.repo) == nil then
        run({ "git", "init", "--bare", state.repo })
    end

    git({ "config", "user.name", "Neovim Config Snapshots" })
    git({ "config", "user.email", "nvim-snapshots@localhost" })
    git({ "config", "core.autocrlf", "false" })
end

local function read_tree(commit, group)
    if commit then
        git({ "read-tree", commit }, { group = group })
    else
        git({ "read-tree", "--empty" }, { group = group })
    end
end

local function worktree_tree(group, base)
    read_tree(base, group)
    git({ "add", "-A", "-f", "--", "." }, { group = group })
    return git({ "write-tree" }, { group = group })
end

local function snapshot_message(title, kind, group, parent)
    title = title:gsub("[\r\n\t]", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if title == "" then
        title = os.date("%H%M %d %B")
    end

    return table.concat({
        title,
        "",
        "Snapshot-Kind: " .. kind,
        "Snapshot-Group: " .. group,
        parent and ("Snapshot-Parent: " .. parent) or nil,
    }, "\n")
end

local function create_snapshot(tree, title, kind, group, parent)
    local id = new_id("snapshot")
    local message = snapshot_message(title, kind, group, parent)
    local commit = git({ "commit-tree", tree, "-m", message }, { group = group })

    git({ "update-ref", snapshot_ref(id), commit }, { group = group })
    git({ "update-ref", group_ref(group), commit }, { group = group })
    return commit, id
end

local function current_tree(group)
    group = group or state.group
    local head = ref_exists(group_ref(group)) and group_head(group) or nil
    return worktree_tree(group, head), head
end

local function is_dirty()
    local tree, head = current_tree()
    if not head then
        return true
    end
    local head_tree = git({ "show", "-s", "--format=%T", head })
    return tree ~= head_tree
end

local function capture(title, kind)
    local tree, parent = current_tree()
    return create_snapshot(tree, title, kind, state.group, parent)
end

local function save_buffers()
    local ok, err = pcall(vim.cmd, "silent wall")
    if not ok then
        notify("Could not save all buffers: " .. tostring(err), vim.log.levels.ERROR)
        return false
    end
    return true
end

local function default_title()
    return os.date("%H%M %d %B")
end

local function cleanup_restart_session()
    local session = vim.env.NVIM_CONFIG_SNAPSHOT_SESSION
    if not session then
        return
    end

    vim.env.NVIM_CONFIG_SNAPSHOT_SESSION = nil
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            vim.uv.fs_unlink(session)
        end,
    })
end

local function hot_reload_fallback(reason)
    notify("Full restart failed; sourcing init.lua instead: " .. reason, vim.log.levels.WARN)
    local ok, err = pcall(vim.cmd, "source " .. vim.fn.fnameescape(vim.env.MYVIMRC))
    if not ok then
        notify(tostring(err), vim.log.levels.ERROR)
    end
end

local function restart()
    local session = state.storage_dir .. "/" .. new_id("restart") .. ".vim"
    local ok, err = pcall(vim.cmd, "silent mksession! " .. vim.fn.fnameescape(session))
    if not ok then
        hot_reload_fallback(tostring(err))
        return
    end

    vim.env.NVIM_CONFIG_SNAPSHOT_RESUME = state.group
    vim.env.NVIM_CONFIG_SNAPSHOT_SESSION = session

    state.restarting = true
    local command = table.concat({
        vim.fn.shellescape(vim.v.progpath),
        "-S",
        vim.fn.shellescape(session),
    }, " ")
    local launched, launch_err = pcall(vim.cmd, "silent !" .. command)
    vim.env.NVIM_CONFIG_SNAPSHOT_RESUME = nil
    vim.env.NVIM_CONFIG_SNAPSHOT_SESSION = nil

    if not launched or vim.v.shell_error ~= 0 then
        state.restarting = false
        vim.uv.fs_unlink(session)
        hot_reload_fallback(tostring(launch_err or "replacement Neovim exited with an error"))
        return
    end

    vim.cmd("qa!")
end

local function delete_ref(ref)
    git({ "update-ref", "-d", ref }, { allow_failure = true })
end

local function prune_old_state(active_group)
    local cutoff = os.time() - (state.retention_days * 24 * 60 * 60)
    local output = git({
        "for-each-ref",
        "--format=%(refname)%09%(creatordate:unix)",
        "refs/config-snapshots",
        "refs/config-snapshot-groups",
    })

    for line in output:gmatch("[^\n]+") do
        local ref, timestamp = line:match("^(.-)\t(%d+)$")
        local is_active = active_group and ref == group_ref(active_group)
        if ref and tonumber(timestamp) < cutoff and not is_active then
            delete_ref(ref)
        end
    end

    for name, kind in vim.fs.dir(state.index_dir) do
        if kind == "file" and name ~= active_group then
            local path = state.index_dir .. "/" .. name
            local stat = vim.uv.fs_stat(path)
            if stat and stat.mtime.sec < cutoff then
                vim.uv.fs_unlink(path)
            end
        end
    end

    for name, kind in vim.fs.dir(state.storage_dir) do
        if kind == "file" and name:match("^restart%-.*%.vim$") then
            local path = state.storage_dir .. "/" .. name
            local stat = vim.uv.fs_stat(path)
            if stat and stat.mtime.sec < cutoff then
                vim.uv.fs_unlink(path)
            end
        end
    end

    git({ "gc", "--quiet", "--prune=" .. state.retention_days .. ".days.ago" }, {
        allow_failure = true,
    })
end

local function start_group()
    local group = new_id("group")
    state.group = group
    local tree = worktree_tree(group)
    create_snapshot(tree, "Started " .. default_title(), "start", group)
end

local function resume_or_start_group()
    local resume = vim.env.NVIM_CONFIG_SNAPSHOT_RESUME
    vim.env.NVIM_CONFIG_SNAPSHOT_RESUME = nil
    prune_old_state(resume)

    if resume and ref_exists(group_ref(resume)) then
        state.group = resume
        read_tree(group_head(resume), resume)
        return
    end

    start_group()
end

local function parse_snapshot(ref, commit, timestamp)
    local metadata = git({ "show", "-s", "--format=%B", commit })
    local title = metadata:match("^([^\n]+)")
    local kind = metadata:match("\nSnapshot%-Kind: ([^\n]+)")
    local group = metadata:match("\nSnapshot%-Group: ([^\n]+)")

    return {
        ref = ref,
        commit = commit,
        timestamp = tonumber(timestamp),
        title = title or commit:sub(1, 8),
        kind = kind or "version",
        group = group,
    }
end

local function snapshots()
    local output = git({
        "for-each-ref",
        "--sort=-creatordate",
        "--format=%(refname)%09%(objectname)%09%(creatordate:unix)",
        "refs/config-snapshots",
    })
    local entries = {}

    for line in output:gmatch("[^\n]+") do
        local ref, commit, timestamp = line:match("^(.-)\t(.-)\t(%d+)$")
        if ref then
            table.insert(entries, parse_snapshot(ref, commit, timestamp))
        end
    end

    return entries
end

-- Diff in the direction a load would apply it: current config on the left,
-- the hovered snapshot on the right.
local function diff_from_current(base_tree, commit)
    local output = git({
        "diff",
        "--no-ext-diff",
        "--stat",
        "--patch",
        base_tree,
        commit,
    })

    if output == "" then
        return { "No differences from the current config." }
    end

    return vim.split(output, "\n", { plain = true })
end

local function checkout_snapshot(entry)
    if not save_buffers() then
        return
    end

    local old_group = state.group
    local old_tree, old_head = current_tree(old_group)
    local old_head_tree = old_head and git({ "show", "-s", "--format=%T", old_head }) or nil
    if old_tree ~= old_head_tree then
        old_head = capture("Before loading " .. entry.title, "autosave")
    end

    local new_group = new_id("group")
    local selected_tree = git({ "show", "-s", "--format=%T", entry.commit })
    local branch_commit, branch_id = create_snapshot(
        selected_tree,
        "Branch from " .. entry.title,
        "branch",
        new_group,
        entry.commit
    )

    read_tree(old_head, new_group)
    local _, code = git({ "read-tree", "--reset", "-u", branch_commit }, {
        group = new_group,
        allow_failure = true,
    })
    if code ~= 0 then
        delete_ref(group_ref(new_group))
        delete_ref(snapshot_ref(branch_id))
        notify("Could not restore " .. entry.title, vim.log.levels.ERROR)
        return
    end

    state.group = new_group
    notify("Loaded " .. entry.title .. " into a new branch")
    restart()
end

function M.cut()
    if not save_buffers() then
        return
    end

    vim.ui.input({
        prompt = "Snapshot title: ",
        default = default_title(),
    }, function(title)
        if title == nil then
            return
        end

        local ok, err = pcall(function()
            capture(title, "version")
        end)
        if not ok then
            notify(tostring(err), vim.log.levels.ERROR)
            return
        end

        notify("Cut snapshot " .. title)
        restart()
    end)
end

function M.load()
    local ok = pcall(require, "telescope")
    if not ok then
        notify("Telescope is required to load snapshots", vim.log.levels.ERROR)
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local config = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local staged, base_tree = pcall(current_tree)
    if not staged then
        notify(tostring(base_tree), vim.log.levels.ERROR)
        return
    end

    pickers.new({}, {
        prompt_title = "Neovim config snapshots",
        previewer = previewers.new_buffer_previewer({
            title = "Changes a load would apply",
            define_preview = function(self, entry)
                local diffed, lines = pcall(diff_from_current, base_tree, entry.value.commit)
                if not diffed then
                    lines = { "Could not diff this snapshot:", tostring(lines) }
                end

                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                vim.bo[self.state.bufnr].filetype = "diff"
            end,
        }),
        finder = finders.new_table({
            results = snapshots(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    ordinal = entry.title .. " " .. entry.kind,
                    display = string.format(
                        "%s  %-8s  %s",
                        os.date("%Y-%m-%d %H:%M", entry.timestamp),
                        entry.kind,
                        entry.title
                    ),
                }
            end,
        }),
        sorter = config.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection then
                    vim.schedule(function()
                        local loaded, load_err = pcall(checkout_snapshot, selection.value)
                        if not loaded then
                            notify(tostring(load_err), vim.log.levels.ERROR)
                        end
                    end)
                end
            end)
            return true
        end,
    }):find()
end

function M.status()
    local ok, dirty = pcall(is_dirty)
    if not ok then
        notify(tostring(dirty), vim.log.levels.ERROR)
        return
    end
    notify(string.format("Group %s is %s", state.group, dirty and "modified" or "clean"))
end

function M.setup(options)
    if state then
        return
    end

    local config = vim.tbl_deep_extend("force", defaults, options or {})
    state = {
        config_root = vim.fn.stdpath("config"),
        storage_dir = config.storage_dir,
        repo = config.storage_dir .. "/objects.git",
        index_dir = config.storage_dir .. "/indexes",
        retention_days = config.retention_days,
    }

    local ok, err = pcall(function()
        initialize_store()
        cleanup_restart_session()
        resume_or_start_group()
    end)
    if not ok then
        state = nil
        notify(tostring(err), vim.log.levels.ERROR)
        return
    end

    vim.api.nvim_create_user_command("ConfigSnapshotCut", M.cut, {
        desc = "Cut and load a named Neovim config snapshot",
    })
    vim.api.nvim_create_user_command("ConfigSnapshotLoad", M.load, {
        desc = "Load a Neovim config snapshot in a new branch",
    })
    vim.api.nvim_create_user_command("ConfigSnapshotStatus", M.status, {
        desc = "Show whether the current config snapshot has changes",
    })

    vim.keymap.set("n", config.keymaps.cut, M.cut, { desc = "Cut config snapshot" })
    vim.keymap.set("n", config.keymaps.load, M.load, { desc = "Load config snapshot" })

    local group = vim.api.nvim_create_augroup("ConfigSnapshots", { clear = true })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            pcall(function()
                if not state.restarting and is_dirty() then
                    capture("Exit " .. default_title(), "autosave")
                end
            end)
        end,
    })
end

return M
