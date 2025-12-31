vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", " ", "", { noremap = true, silent = true })

-- PLUGINS
require("config.neoplug").setup({
    path = "plugins",
    extra = {
        { slug = "nvim-tree/nvim-web-devicons", priority = 999 },
    }
})

require("custom")

vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
