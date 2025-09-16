-- See ':help lsp-attach' and ':help lsp-defaults-disable'

local set = vim.keymap.set

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)

        local opts = { noremap = true, silent = true, buffer = args.buf }

        set("n", "gd", vim.lsp.buf.definition, opts)
        set("n", "gD", vim.lsp.buf.declaration, opts)
        set("n", "gr", vim.lsp.buf.references, opts)
        set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        set("n", "]d", function()
            vim.diagnostic.jump({ count = 1, wrap = true })
        end, opts)

        set("n", "[d", function()
            vim.diagnostic.jump({ count = -1, wrap = true })
        end, opts)

        set("n", "<leader>d", function()
            vim.diagnostic.open_float(nil, { scope = "cursor" })
        end, opts)
    end,
})
