---@type plugin_spec
local M = { slug = 'neovim/nvim-lspconfig' }

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client.server_capabilities and client.server_capabilities.signatureHelpProvider then
            vim.api.nvim_create_autocmd("InsertCharPre", {
                buffer = args.buf,
                callback = function()
                    local char = vim.v.char
                    if char == '(' or char == ' ' then
                        vim.defer_fn(function()
                            vim.lsp.buf.signature_help({ silent = true })
                        end, 75)
                    end
                end,
            })
        end
    end,
})

vim.keymap.set('i', '<C-k>', function() vim.lsp.buf.hover({ silent = true, zindex = 10000 }) end)

return M
