---@type plugin_spec
return {
    slug = "L3MON4D3/LuaSnip",
    priority = 100,
    config = function()
        local ls = require("luasnip")
        local i = ls.insert_node
        local t = ls.text_node
        local f = ls.function_node
        local c = ls.choice_node

        local fmt = require("luasnip.extras.fmt").fmt
        local rep = require("luasnip.extras").rep

        vim.keymap.set({ "i" }, "<C-J>", function()
            if not ls.expand() then
                ls.jump(1)
            end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<C-L>", function()
            ls.jump(-1)
        end, { silent = true })

        vim.keymap.set("i", "<C-H>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { silent = true })

        --- Global snippets
        ls.add_snippets("all", {
            ls.snippet("date", {
                f(function()
                    return os.date("%D - %H:%M")
                end)
            })
        })

        --- C snippets
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

            -- Use a condition node for common array traversal case
            ls.snippet("for", fmt("for ({}) {{\n\t{}\n}}{}", {
                c(1, {
                    i(1),
                    { t("int i = 0; i < "), i(1), t("; ++i") }
                }), i(2), i(0)
            })),

            ls.snippet("while", fmt("while ({}) {{\n\t{}\n}}{}", { i(1), i(2), i(0) })),

            -- See TJ video "advanced luasnip" for funciton and dynamic nodes to
            -- do this properly
            ls.snippet("err", fmt("if ({})\n\terrExit(\"{}\");", { i(1), rep(1) })),

            ls.snippet("inc", fmt("#include {}{}", {
                c(1, {
                    { t("<"), i(1), t(">") },
                    { t("\""), i(1), t("\"") },
                }),
                i(0),
            })),

            ls.snippet("main", fmt("int main({})\n{{\n\t{}\n{}}}", {
                c(1, {
                    t("void"),
                    t("int argc, char **argv"),
                }),
                i(2),
                i(0),
            })),

            ls.snippet("func", fmt("{}({})\n{{\n\t{}\n}}{}", {
                i(1), i(2), i(3), i(0)
            })),

            ls.snippet("ifndef", fmt("#ifndef {}\n#define {}\n\n#endif{}", {
                i(1), rep(1), i(0)
            })),
        })

        ls.filetype_extend("h", { "c" })
    end,
}
