local M = {}

M.name = "neovim/nvim-lspconfig"
M.enabled = false

M.expects = {
    "hrsh7th/nvim-cmp",
}

function M.config()
    local set = vim.keymap.set

    --- @diagnostic disable-next-line: unused-local
    local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }

        set("n", "gd", vim.lsp.buf.definition, opts)
        set("n", "gD", vim.lsp.buf.declaration, opts)
        set("n", "gr", vim.lsp.buf.references, opts)
        set("n", "ca", vim.lsp.buf.code_action, opts)
        set("n", "rn", vim.lsp.buf.rename, opts)
        set("n", "[d", vim.diagnostic.goto_prev, opts)
        set("n", "]d", vim.diagnostic.goto_next, opts)
        set("n", "<leader>d", function()
            vim.diagnostic.open_float(nil, { scope = "cursor" })
        end, opts)
    end

    local lsp = require("lspconfig")

    local clangdopts = {
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        cmd = {
            "clangd",
            "--completion-style=detailed",
            "--function-arg-placeholders=0",
            "--clang-tidy",
            "--fallback-style=Microsoft",
        },
    }

    local luaopts = {
        on_attach = on_attach,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = {
                    library = {
                        vim.api.nvim_get_runtime_file("", true),
                    }
                }
            }
        }
    }

    lsp.clangd.setup(clangdopts)
    lsp.lua_ls.setup(luaopts)
end

return M
