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
require("custom.fzf")
require("custom.statusline")

vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
