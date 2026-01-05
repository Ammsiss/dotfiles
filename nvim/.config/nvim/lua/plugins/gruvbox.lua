---@type plugin_spec
local M = {
    slug = "ellisonleao/gruvbox.nvim",
    priority = 1000,
}

local gb = require("custom.color").gruvbox

function M.config()
    require("gruvbox").setup({
        -- terminal_colors = true,
        -- undercurl = true,
        -- underline = true,
        -- bold = true,
        -- italic = {
        --     strings = true,
        --     emphasis = true,
        --     comments = true,
        --     operators = false,
        --     folds = true,
        -- },
        -- strikethrough = true,
        -- invert_selection = false,
        -- invert_signs = false,
        -- invert_tabline = false,
        -- inverse = true,
        -- contrast = "",
        -- palette_overrides = {},
        overrides = {
            Visual = { fg = "NONE", bg = "#6B492A" },
            Search = { fg = gb.bright_blue, reverse = true },
            CurSearch = { fg = gb.bright_green, reverse = true},
            FloatBorder = { fg = gb.bright_blue },
            TabLine = { fg = gb.gray, bg = "NONE" },
            TabLineSel = { fg = gb.bright_orange, bg = "NONE" },
            TabLineFill = { fg = "NONE", bg = "NONE" },
            StatusLine = { fg = "#ebdbb2", bg = "NONE", bold = true },
            StatusLineFilename = { fg = "#E67E22", bg = "NONE" },
            StatusLineNC = { fg = "#bdae93", bg = "NONE" },
        },
        -- dim_inactive = false,
        transparent_mode = true,
    })
    vim.cmd("colorscheme gruvbox")
    vim.opt.background = "dark"
end

return M
