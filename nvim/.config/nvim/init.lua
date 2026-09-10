vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", " ", "", { noremap = true, silent = true })

require("custom.opts")
require("custom.autocmd")

-- PLUGINS
require("config.neoplug").setup({
    path = "plugins",
    extra = {
        { slug = "nvim-tree/nvim-web-devicons", priority = 999 },
    }
})

require("custom.binds")
require("custom.statusline")
require("custom.filetree");

vim.lsp.enable("emmylua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("asm_lsp")
vim.g.c_syntax_for_h = 1 -- .h files recognized as c not cpp
