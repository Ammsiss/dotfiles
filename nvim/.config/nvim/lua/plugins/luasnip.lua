---@type plugin_spec
return {
    slug = "L3MON4D3/LuaSnip",
    priority = 100,
    config = function()
        local ls = require("luasnip")
        local i = ls.insert_node
        local t = ls.text_node
        local f = ls.function_node

        local fmt = require("luasnip.extras.fmt").fmt
        local rep = require("luasnip.extras").rep

        vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump( 1) end, { silent = true })
        vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(-1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-S>", function() ls.expand() end, { silent = true })

        ls.add_snippets("all", {
            ls.snippet("date", {
                f(function()
                    return os.date("%D - %H:%M")
                end)
            })
        })

        ls.add_snippets("c", {
            ls.snippet("tern", {
                i(1, "cond"), t(" ? "), i(2, "a"), t(" : "), i(3, "b"), i(0)
            }),

            ls.snippet("if", {
                t("if ("), i(1, "cond"), t({ ") {", "\t" }),
                i(2),
                t({ "", "}" })
            }),
            ls.snippet("else if", {
                t("else if ("), i(1, "cond"), t({ ") {", "\t" }),
                i(2),
                t({ "", "}" })
            }),
            ls.snippet("else", {
                t({ "else {", "\t" }),
                i(1),
                t({ "", "}" })
            }),

            ls.snippet("switch", {
                t("switch ("), i(1, "expr"), t({ ") {", "" }),
                i(2),
                t({ "", "}" }),
            }),
            ls.snippet("case", {
                t("case "), i(1), t({ ":", "\t" }),
                i(2),
            }),

            -- See TJ video "advanced luasnip" for funciton and dynamic nodes to
            -- do this properly
            ls.snippet("err", fmt("if ({})\n\terrExit(\"{}\");", { i(1), rep(1) })),
        })
    end,
}
