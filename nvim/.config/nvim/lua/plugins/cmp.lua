---@type plugin_spec
local M = { slug = "hrsh7th/nvim-cmp", priority = 0 }

M.expects = {
    { slug = "hrsh7th/cmp-nvim-lsp", priority = 100 },
    { slug = "hrsh7th/cmp-path", priority = 100 },
    { slug = "hrsh7th/cmp-buffer", priority = 100 },
    { slug = "hrsh7th/cmp-cmdline", priority = 100 },
}

function M.config()
    local cmp = require("cmp")

    -- Global setup
    cmp.setup({
        mapping = {
            ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        },
        window = {
            -- See PR#1812
            -- documentation = cmp.config.window.bordered(),
            completion = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
        }, {
            { name = "buffer" },
        }),
        view = {
            docs = {
                auto_open = false
            }
        }
    })

    -- `/` and '?' cmdline setup.
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            {
                name = 'cmdline',
                option = {
                    ignore_cmds = {}
                }
            }
        })
    })

    -- Setup lspconfig.
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    vim.lsp.config("lua_ls", { capabilities = capabilities })
    vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = {
            "clangd",
            "--header-insertion-decorators=false", -- See #999
            "--function-arg-placeholders=0"
        }
    })
end

return M
