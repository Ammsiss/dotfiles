local root_files = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac',
    'Makefile',
    '.gitignore',
}

local set = vim.keymap.set
local on_attach = function(_, bufnr)

    local opts = { noremap = true, silent = true, buffer = bufnr }

    set("n", "gd", vim.lsp.buf.definition, opts)
    set("n", "gD", vim.lsp.buf.declaration, opts)
    set("n", "gr", vim.lsp.buf.references, opts)
    set("n", "ca", vim.lsp.buf.code_action, opts)
    set("n", "rn", vim.lsp.buf.rename, opts)
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
    cmd = {
        "clangd",
        "--clang-tidy",
        "--background-index",
        "--completion-style=detailed",
        "--function-arg-placeholders=0",
        "--fallback-style=Microsoft",
    },
    filetypes = { "cpp", "hpp", "c", "h" },
    root_markers = root_files,
    on_attach = on_attach
}
