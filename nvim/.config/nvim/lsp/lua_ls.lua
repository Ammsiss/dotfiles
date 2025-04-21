local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

local set = vim.keymap.set
local on_attach = function(_, bufnr) -- client
    local opts = { noremap = true, silent = true, buffer = bufnr }

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
end

return {
  cmd = { 'lua-language-server' },
  filetypes = {'lua'},
  root_markers = root_files,
  on_attach = on_attach
}
