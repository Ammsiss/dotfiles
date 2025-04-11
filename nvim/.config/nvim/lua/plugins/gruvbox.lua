local M = {}

M.name = "ellisonleao/gruvbox.nvim"
M.enabled = true
M.priority = 1000

function M.config()
    require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = true,
            emphasis = true,
            comments = true,
            operators = false,
            folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,    -- invert background for search, diffs, statuslines and errors
        contrast = "hard", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {
            Visual = { bg = "#66B2B2" },
            Search = { fg = "#6A9E9E" },
            IncSearch = { fg = "#E67E22" },
            MatchParen = { bg = "#6A9E9E" },
        },
        dim_inactive = false,
        transparent_mode = true,
    })
    vim.cmd("colorscheme gruvbox")
end

return M
