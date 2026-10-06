-- nvim-treesitter's master branch supports Neovim 0.10/0.11 only, and 0.12 changed
-- query directives to receive a list of nodes per capture instead of one node. Its
-- markdown/html directives still index that list as a node, so any markdown buffer
-- (including every LSP hover popup) throws "attempt to call method 'range'".
--
-- Delete this file when migrating to the nvim-treesitter main branch.
if vim.fn.has("nvim-0.12") == 0 then
    return
end

local query = require("vim.treesitter.query")

local info_string_aliases = {
    ex = "elixir",
    pl = "perl",
    sh = "bash",
    uxn = "uxntal",
    ts = "typescript",
}

local script_type_languages = {
    ["importmap"] = "json",
    ["module"] = "javascript",
    ["application/ecmascript"] = "javascript",
    ["text/ecmascript"] = "javascript",
}

local function capture_node(match, id)
    local value = match[id]
    if type(value) == "table" then
        return value[#value]
    end
    return value
end

local opts = { force = true, all = false }

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local node = capture_node(match, pred[2])
    if not node then
        return
    end
    local alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata["injection.language"] = vim.filetype.match({ filename = "a." .. alias })
        or info_string_aliases[alias]
        or alias
end, opts)

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local node = capture_node(match, pred[2])
    if not node then
        return
    end
    local mimetype = vim.treesitter.get_node_text(node, bufnr)
    if script_type_languages[mimetype] then
        metadata["injection.language"] = script_type_languages[mimetype]
    else
        local parts = vim.split(mimetype, "/", {})
        metadata["injection.language"] = parts[#parts]
    end
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = capture_node(match, id)
    if not node then
        return
    end
    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
    if not metadata[id] then
        metadata[id] = {}
    end
    metadata[id].text = string.lower(text)
end, opts)
