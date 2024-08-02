local ls = require "luasnip"
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("rust", {
    s("ts", {
        t('Token {'),
        t({"", '\tkind: Ok(TokenKind::Symbol(Symbol::'}),
        i(1),
        t(")),"),
        t({"", "\tstart_end_position: (0, 0),"}),
        t({"", "\tline: 0,"}),
        t({"", "\trepresentation: \"\".to_string(),"}),
        t({"", "},"}),
    })
})

ls.add_snippets("rust", {
    s("tk", {
        t('Token {'),
        t({"", '\tkind: Ok(TokenKind::Keyword(Keyword::'}),
        i(1),
        t(")),"),
        t({"", "\tstart_end_position: (0, 0),"}),
        t({"", "\tline: 0,"}),
        t({"", "\trepresentation: \"\".to_string(),"}),
        t({"", "},"}),
    })
})

ls.add_snippets("rust", {
    s("td", {
        t('Token {'),
        t({"", '\tkind: Ok(TokenKind::Digit(Digit { value: '}),
        i(1),
        t(" })),"),
        t({"", "\tstart_end_position: (0, 0),"}),
        t({"", "\tline: 0,"}),
        t({"", "\trepresentation: \"\".to_string(),"}),
        t({"", "},"}),
    })
})

ls.add_snippets("rust", {
    s("tc", {
        t('Token {'),
        t({"", '\tkind: Ok(TokenKind::Char(Char { letter: \''}),
        i(1),
        t("\' })),"),
        t({"", "\tstart_end_position: (0, 0),"}),
        t({"", "\tline: 0,"}),
        t({"", "\trepresentation: \"\".to_string(),"}),
        t({"", "},"}),
    })
})

ls.add_snippets("rust", {
    s("ti", {
        t('Token {'),
        t({"", '\tkind: Ok(TokenKind::Id(Id { name: \''}),
        i(1),
        t("\' })),"),
        t({"", "\tstart_end_position: (0, 0),"}),
        t({"", "\tline: 0,"}),
        t({"", "\trepresentation: \"\".to_string(),"}),
        t({"", "},"}),
    })
})

vim.keymap.set({"i"}, "<C-y>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

