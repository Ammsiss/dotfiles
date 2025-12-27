vim.opt.formatoptions = "jtcqln"

vim.opt.path = ".,**"

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel = 999 -- So shits not foldy at start

vim.opt.conceallevel = 2
vim.opt.textwidth = 64 -- Width of macos screen with vsp

local gruvbox = require("custom.color").gruvbox

-- Potentially have another table that stores 'val' tables
-- so you can reuse colors without have to respecify

local groups = {
    MyMarkupYellow = { fg = gruvbox.bright_yellow },
    MyMarkupGreen =  { fg = gruvbox.bright_green },
    MyMarkupPurple = { fg = gruvbox.bright_purple },
    MyMarkupRed =    { fg = gruvbox.bright_red },
    MyMarkupOrange = { fg = gruvbox.bright_orange },
    MyMarkupBlue =    { fg = gruvbox.bright_blue },

    MyMarkupBold = { bold = true, fg = gruvbox.bright_aqua },
    MyMarkupItalic = { italic = true, fg = gruvbox.bright_aqua },
    MyMarkupStrikethrough = { strikethrough = true, italic = true, fg = gruvbox.light_red },
    MyMarkupRaw = { bold = true, fg = "#83a598", bg = "#302F2F"},
    MyMarkupRawBlock = { fg = "#83a598" },
    MyMarkupLinkLabel = { underline = true, fg = "#83a598" },
    MyMarkupHeading1 = { bold = true, underdouble = true, fg = gruvbox.bright_yellow },
    MyMarkupHeading2 = { bold = true, underdouble = true, fg = gruvbox.bright_green },
    MyMarkupHeading3 = { bold = true, underdouble = true,  fg = gruvbox.bright_purple },
    MyMarkupHeading4 = { bold = true, underdouble = true, fg = gruvbox.bright_red },
    MyMarkupHeading5 = { bold = true, underdouble = true, fg = gruvbox.bright_orange },
    MyMarkupHeading6 = { bold = true, underdouble = true,  fg = gruvbox.bright_blue },

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

local mark_ns = vim.api.nvim_create_namespace('MarkdownRendering')

-- TABLE RENDERING

-- See md_features.md for table render ideas

-- BLOCK QUOTES

local blockquote_query = vim.treesitter.query.parse("markdown", "((block_quote_marker) @str)")
local blockquote_cont_query = vim.treesitter.query.parse("markdown",
    "((block_continuation) @str (#has-ancestor? @str block_quote))")

-- In order to query inline stuff you need to query the markdown-inline parser
-- local shortcut_query = vim.treesitter.query.parse("markdown", "((shortcut_link) @str)")

local function refresh_blockquote(bufnr)
    bufnr = bufnr or 0

    -- pass this in
    local parser = vim.treesitter.get_parser(bufnr, "markdown")
    if not parser then
        vim.notify("Error: get_parser", vim.log.levels.ERROR)
        return
    end

    local tree = parser:parse()[1]

    for _, node, _, _ in blockquote_query:iter_captures(tree:root(), bufnr) do
        local sl, sc, _, _ = node:range()

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
            { hl_group = "MyMarkupBlue", end_col = sc + 1, conceal = "▉" })
    end

    for _, node, _, _ in blockquote_cont_query:iter_captures(tree:root(), bufnr) do
        local sl, sc, _, _ = node:range()

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
            { hl_group = "MyMarkupBlue", end_col = sc + 1, conceal = "▉" })
    end

    -- for _, node, _, _ in shortcut_query:iter_captures(tree:root(), bufnr) do
    --     local sl, sc, _, ec = node:range()
    --
    --     vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
    --         { hl_group = "MyMarkupPurple", end_col = ec, conceal = "" })
    --     vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
    --         { virt_text = { { "ⓘ INFO", "MyMarkupBlue" } } })
    -- end
end
refresh_blockquote()


-- CHECKBOX RENDERING

local checked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_checked) @str)")
local unchecked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_unchecked) @str)")

local function refresh_checkbox(bufnr)
    bufnr = bufnr or 0

    -- pass this in
    local parser = vim.treesitter.get_parser(bufnr, "markdown")
    if not parser then
        vim.notify("Error: get_parser", vim.log.levels.ERROR)
        return
    end

    local tree = parser:parse()[1]

    for _, node, _, _ in checked_query:iter_captures(tree:root(), bufnr) do
        local sl, sc, _, ec = node:range()

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
            { hl_group = "MyMarkupPurple", end_col = ec, conceal = "☑" })
    end

    for _, node, _, _ in unchecked_query:iter_captures(tree:root(), bufnr) do
        local sl, sc, _, ec = node:range()

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
            { hl_group = "MyMarkupPurple", end_col = ec, conceal = "☐" })
    end
end
refresh_checkbox()

-- LINK RENDERING

-- local bullet_query = vim.treesitter.query.parse("markdown", "((list_marker_minus) @str)")
-- local number_query = vim.treesitter.query.parse("markdown", "((list_marker_dot) @str)")
--
-- local function refresh_lists(bufnr)
--     bufnr = bufnr or 0
--
--     local parser = vim.treesitter.get_parser(bufnr, "markdown")
--     if not parser then
--         vim.notify("Error: get_parser", vim.log.levels.ERROR)
--         return
--     end
--
--     local tree = parser:parse()[1]
--
--     for _, node, _, _ in bullet_query:iter_captures(tree:root(), bufnr) do
--         local sl, sc, _, _ = node:range()
--
--         vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
--             { hl_group = "MyMarkupPurple", end_col = sc + 1, conceal = "•" })
--     end
--
--     for _, node, _, _ in number_query:iter_captures(tree:root(), bufnr) do
--         local sl, sc, _, _ = node:range()
--
--         vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
--             { virt_text = { { " ", "MyMarkupPurple" } }, virt_text_pos = "inline" })
--     end
-- end
-- refresh_lists()

-- HEADER RENDERING

local header_node_names = {
    "atx_h1_marker", "atx_h2_marker", "atx_h3_marker", "atx_h4_marker",
    "atx_h5_marker", "atx_h6_marker"
}

local queries = {}
for _, name in ipairs(header_node_names) do
    local query_str = "((" .. name .. ") @str)"
    table.insert(queries, vim.treesitter.query.parse('markdown', query_str))
end

local conceal_chars = { "①", "②", "③", "④", "⑤", "⑥" }

local function refresh_header(bufnr)
    bufnr = bufnr or 0

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
            vim.api.nvim_buf_clear_namespace(args.buf, mark_ns, 0, -1)
            refresh_header(args.buf)
            refresh_checkbox(args.buf)
            refresh_blockquote(args.buf)
        end)
    end,
})
