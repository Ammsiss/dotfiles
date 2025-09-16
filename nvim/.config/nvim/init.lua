-- Set map leader before loading plugin/custom lua files
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", " ", "", { noremap = true, silent = true })

-- PLUGINS
require("config.neoplug").setup({
    path = "plugins",
    extra = {
        { name = "nvim-tree/nvim-web-devicons", priority = 999 },
    }
}, { auto_update = true, ui = { border = "rounded" }})

-- CUSTOM
require("custom")

-- LSP SETUP
-- (see https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs)
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("omnisharp")

-- Global Vim Color Highlights (#E67E22 = Orange)
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#60898a", bg = "NONE" })

-- Command mode completion popup highlights
-- vim.api.nvim_set_hl(0, "Pmenu", { fg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#b8bb26", bg = "NONE" })      -- Highlight selected item
-- vim.api.nvim_set_hl(0, "PmenuSbar", { fg = "NONE", bg = "NONE" })        -- Scrollbar background
vim.api.nvim_set_hl(0, "PmenuThumb", { fg = "#b8bb26", bg = "#b8bb26" }) -- Scrollbar thumb

-- Status bar
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#ebdbb2", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "StatusLineFilename", { fg = "#E67E22", bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#bdae93", bg = "NONE" })

-- Tab Line
vim.api.nvim_set_hl(0, "TabLine", { fg = "#bdae93", bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#E67E22", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = "NONE", bg = "NONE" })
