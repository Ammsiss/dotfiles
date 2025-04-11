-- Set map leader before loading plugin/custom lua files
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", " ", "", { noremap = true, silent = true })

require("config.neoplug").setup({
    path = "plugins",
    extra = {
        { name = "nvim-tree/nvim-web-devicons", priority = 999 },
        { name = "nvim-lua/plenary.nvim" },
        { name = "hrsh7th/cmp-nvim-lsp", enabled = true },
        { name = "hrsh7th/cmp-path", enabled = true },
        { name = "hrsh7th/cmp-buffer", enabled = true },
    }
}, { auto_update = true, ui = { border = "rounded" }})
require("custom")

-- LSP SETUP
vim.lsp.enable("lua_ls")

-- Global Vim Color Highlights (#E67E22 = Orange)
vim.api.nvim_set_hl(0, "NormalFloat", { fg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#E67E22", bg = "NONE" })

-- Command mode completion popup highlights
vim.api.nvim_set_hl(0, "Pmenu", { fg = "NONE", bg = "NONE" })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#E67E22", bg = "NONE" })      -- Highlight selected item
vim.api.nvim_set_hl(0, "PmenuSbar", { fg = "NONE", bg = "NONE" })        -- Scrollbar background
vim.api.nvim_set_hl(0, "PmenuThumb", { fg = "#E67E22", bg = "#E67E22" }) -- Scrollbar thumb

-- Status bar
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#E67E22", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#E67E22", bg = "#3c3836" })
vim.api.nvim_set_hl(0, "StatusLineFilename", { fg = "#bdae93", bg = "#3c3836" })

-- Tab Line
vim.api.nvim_set_hl(0, "TabLine", { fg = "#bdae93", bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#E67E22", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = "NONE", bg = "NONE" })
