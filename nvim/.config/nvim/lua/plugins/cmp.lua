---@type plugin_spec
local M = {
    name = "hrsh7th/nvim-cmp",
    enabled = true
}

M.expects = {
    { name = "hrsh7th/cmp-nvim-lsp", enabled = true },
    { name = "hrsh7th/cmp-path", enabled = true },
    { name = "hrsh7th/cmp-buffer", enabled = true },
    { name = "hrsh7th/cmp-nvim-lsp-signature-help", enabled = true },
}

function M.config()
    local cmp = require("cmp")

    cmp.setup {
        sources = {
            { name = "nvim_lsp", priority = 1000 },
            { name = "path",     priority = 750 },
            { name = "buffer",   priority = 500 },
            { name = "nvim_lsp_signature_help" },
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
    vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#60898a", bg = "NONE" })
end

return M
