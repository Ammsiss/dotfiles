local M = {}

M.name = "hrsh7th/nvim-cmp"
M.enabled = true

M.expects = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
}

function M.config()
    local cmp = require("cmp")

    cmp.setup {
        sources = {
            { name = "nvim_lsp", priority = 1000 },
            { name = "path",     priority = 750 },
            { name = "buffer",   priority = 500 },
        },
        mapping = {
            ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
            ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
            ["<C-y>"] = cmp.mapping(
                cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                },
                { "i", "c" }
            ),
        },
        window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
            }),
            documentation = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
            }),
        },
    }

    vim.api.nvim_set_hl(0, "CmpNormal", { fg = "NONE", bg = "NONE" })
    vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#E67E22", bg = "NONE" })
end

return M
