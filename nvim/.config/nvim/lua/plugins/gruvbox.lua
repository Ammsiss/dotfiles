---@type plugin_spec
local M = {
    slug = "ellisonleao/gruvbox.nvim",
    priority = 1000,
}

local gb = require("custom.color").gruvbox

function M.config()
    require("gruvbox").setup({
        overrides = {
            Visual = { fg = "NONE", bg = gb.visual_orange },
            Search = { fg = "NONE", bg = gb.faded_aqua },
            CurSearch = { fg = "NONE", bg = "#6B492A" },
            IncSearch = { fg = "NONE", bg = "#6B492A" },
            FloatBorder = { fg = gb.bright_blue },
            TabLine = { fg = gb.gray, bg = "NONE" },
            TabLineSel = { fg = gb.bright_orange, bg = "NONE" },
            TabLineFill = { fg = "NONE", bg = "NONE" },
            StatusLine = { fg = "#ebdbb2", bg = "NONE", bold = true },
            StatusLineFilename = { fg = "#E67E22", bg = "NONE" },
            StatusLineNC = { fg = "#bdae93", bg = "NONE" },
        },
        inverse = false,
        transparent_mode = true,
    })
    vim.cmd("colorscheme gruvbox")
    vim.opt.background = "dark"
end

return M
