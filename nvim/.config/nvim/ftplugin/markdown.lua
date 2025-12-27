vim.opt.formatoptions = "jtcqln"

vim.opt.path = ".,**"

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel = 999 -- So shits not foldy at start

vim.opt.conceallevel = 2
vim.opt.textwidth = 64 -- Width of macos screen with vsp

---@type table<string, string>
local gb_col = {
    dark0_hard = "#1d2021",
    dark0 = "#282828",
    dark0_soft = "#32302f",
    dark1 = "#3c3836",
    dark2 = "#504945",
    dark3 = "#665c54",
    dark4 = "#7c6f64",
    light0_hard = "#f9f5d7",
    light0 = "#fbf1c7",
    light0_soft = "#f2e5bc",
    light1 = "#ebdbb2",
    light2 = "#d5c4a1",
    light3 = "#bdae93",
    light4 = "#a89984",
    bright_red = "#fb4934",
    bright_green = "#b8bb26",
    bright_yellow = "#fabd2f",
    bright_blue = "#83a598",
    bright_purple = "#d3869b",
    bright_aqua = "#8ec07c",
    bright_orange = "#fe8019",
    neutral_red = "#cc241d",
    neutral_green = "#98971a",
    neutral_yellow = "#d79921",
    neutral_blue = "#458588",
    neutral_purple = "#b16286",
    neutral_aqua = "#689d6a",
    neutral_orange = "#d65d0e",
    faded_red = "#9d0006",
    faded_green = "#79740e",
    faded_yellow = "#b57614",
    faded_blue = "#076678",
    faded_purple = "#8f3f71",
    faded_aqua = "#427b58",
    faded_orange = "#af3a03",
    dark_red_hard = "#792329",
    dark_red = "#722529",
    dark_red_soft = "#7b2c2f",
    light_red_hard = "#fc9690",
    light_red = "#fc9487",
    light_red_soft = "#f78b7f",
    dark_green_hard = "#5a633a",
    dark_green = "#62693e",
    dark_green_soft = "#686d43",
    light_green_hard = "#d3d6a5",
    light_green = "#d5d39b",
    light_green_soft = "#cecb94",
    dark_aqua_hard = "#3e4934",
    dark_aqua = "#49503b",
    dark_aqua_soft = "#525742",
    light_aqua_hard = "#e6e9c1",
    light_aqua = "#e8e5b5",
    light_aqua_soft = "#e1dbac",
    gray = "#928374",
}

-- Potentially have another table that stores 'val' tables
-- so you can reuse colors without have to respecify

local groups = {
    MyMarkupYellow = { fg = gb_col.bright_yellow },
    MyMarkupGreen =  { fg = gb_col.bright_green },
    MyMarkupPurple = { fg = gb_col.bright_purple },
    MyMarkupRed =    { fg = gb_col.bright_red },
    MyMarkupOrange = { fg = gb_col.bright_orange },
    MyMarkupBlue =    { fg = gb_col.bright_blue },

    MyMarkupBold = { bold = true, fg = gb_col.bright_aqua },
    MyMarkupItalic = { italic = true, fg = gb_col.bright_aqua },
    MyMarkupStrikethrough = { strikethrough = true, italic = true, fg = gb_col.light_red },
    MyMarkupRaw = { bold = true, fg = "#83a598", bg = "#302F2F"},
    MyMarkupRawBlock = { fg = "#83a598" },
    MyMarkupLinkLabel = { underline = true, fg = "#83a598" },
    MyMarkupHeading1 = { bold = true, underdouble = true, fg = gb_col.bright_yellow },
    MyMarkupHeading2 = { bold = true, underdouble = true, fg = gb_col.bright_green },
    MyMarkupHeading3 = { bold = true, underdouble = true,  fg = gb_col.bright_purple },
    MyMarkupHeading4 = { bold = true, underdouble = true, fg = gb_col.bright_red },
    MyMarkupHeading5 = { bold = true, underdouble = true, fg = gb_col.bright_orange },
    MyMarkupHeading6 = { bold = true, underdouble = true,  fg = gb_col.bright_blue },

    ["@markup.strong.markdown_inline"] = { link = "MyMarkupBold" },
    ["@markup.italic.markdown_inline"] = { link = "MyMarkupItalic" },
    ["@markup.strikethrough.markdown_inline"] = { link = "MyMarkupStrikethrough" },
    ["@markup.raw.markdown_inline"] = { link = "MyMarkupRaw" },
    ["@markup.raw.block.markdown_inline"] = { link = "MyMarkupRawBlock" },
    ["@markup.link.label.markdown_inline"] = { link = "MyMarkupLinkLabel" },
    ["@markup.heading.1.markdown"] = { link = "MyMarkupHeading1" },
    ["@markup.heading.2.markdown"] = { link = "MyMarkupHeading2" },
    ["@markup.heading.3.markdown"] = { link = "MyMarkupHeading3" },
    ["@markup.heading.4.markdown"] = { link = "MyMarkupHeading4" },
    ["@markup.heading.5.markdown"] = { link = "MyMarkupHeading5" },
    ["@markup.heading.6.markdown"] = { link = "MyMarkupHeading6" },
}

for name, val in pairs(groups) do
    vim.api.nvim_set_hl(0, name, val)
end

local node_names = {
    "atx_h1_marker", "atx_h2_marker", "atx_h3_marker", "atx_h4_marker",
    "atx_h5_marker", "atx_h6_marker"
}

local conceal_chars = { "①", "②", "③", "④", "⑤", "⑥" }

local mark_ns = vim.api.nvim_create_namespace('MarkdownRendering')

local queries = {}
for _, name in ipairs(node_names) do
    local query_str = "((" .. name .. ") @str)"
    table.insert(queries, vim.treesitter.query.parse('markdown', query_str))
end

local function refresh_header(bufnr)
    bufnr = bufnr or 0

    -- Nuke all previous extmarks
    vim.api.nvim_buf_clear_namespace(bufnr, mark_ns, 0, -1)

    local parser = vim.treesitter.get_parser(bufnr, "markdown")
    if not parser then
        vim.notify("Error: get_parser", vim.log.levels.ERROR)
        return
    end

    local tree = parser:parse()[1]

    local sign_colors = {
        "MyMarkupYellow",
        "MyMarkupGreen",
        "MyMarkupPurple",
        "MyMarkupRed",
        "MyMarkupOrange",
        "MyMarkupBlue",
    }

    for i, query in ipairs(queries) do
        -- Gather captures for each query
        for _, node, _, _ in query:iter_captures(tree:root(), bufnr) do

            local sl, sc, _, ec = node:range()
            local hl = "MyMarkupHeading" .. i

            vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc, {
                hl_group = hl, end_col = ec, conceal = conceal_chars[i],
                sign_text = "⇒", sign_hl_group = sign_colors[i]
            })
        end
    end
end
refresh_header()

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP"  }, {
    buffer = 0,
    callback = function(args)
        vim.schedule(function()
            refresh_header(args.buf)
        end)
    end,
})
