vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldlevel = 999

vim.opt_local.path = ".,**" -- For opening photos in []

vim.opt_local.formatoptions = "jtcqln"
vim.opt_local.textwidth = 64
vim.opt_local.wrap = false
vim.opt_local.conceallevel = 2

-- HIGHLIGHTS

local gruvbox = require("custom.color").gruvbox

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
    MyMarkupRaw = { bold = true, fg = "#83a598" },
    MyMarkupRawBlock = { fg = "#83a598" },
    MyMarkupLinkLabel = { underline = true, fg = "#83a598" },
    MyMarkupHeading1 = { bold = true, underdouble = true, fg = gruvbox.bright_yellow },
    MyMarkupHeading2 = { bold = true, underline = true, fg = gruvbox.bright_green },
    MyMarkupHeading3 = { bold = true, underdouble = true,  fg = gruvbox.bright_purple },
    MyMarkupHeading4 = { bold = true, underline = true, fg = gruvbox.bright_red },
    MyMarkupHeading5 = { bold = true, underline = true, fg = gruvbox.bright_orange },
    MyMarkupHeading6 = { bold = true, underline = true,  fg = gruvbox.bright_blue },

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

-- RENDERING

-- TABLE
    -- See md_features.md for table render ideas

-- BLOCK QUOTES

local blockquote_query = vim.treesitter.query.parse("markdown", "((block_quote_marker) @str)")
local blockquote_cont_query = vim.treesitter.query.parse("markdown",
    "((block_continuation) @str (#has-ancestor? @str block_quote))")

local function refresh_blockquote(bufnr, mark_ns, tree)
    bufnr = bufnr or 0

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
end

-- CHECKBOX

local checked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_checked) @str)")
local unchecked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_unchecked) @str)")
local check_marker_query = vim.treesitter.query.parse("markdown",
    "(list_item (list_marker_minus) @task_bullet [(task_list_marker_unchecked) (task_list_marker_checked)])")

local function refresh_checkbox(bufnr, mark_ns, tree)
    bufnr = bufnr or 0

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

    for _, node, _, _ in check_marker_query:iter_captures(tree:root(), bufnr) do
        local sl, sc, _, ec = node:range()

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
            { hl_group = "MyMarkupPurple", end_col = ec, conceal = "" })
    end
end

-- LIST

local bullet_query = vim.treesitter.query.parse("markdown", "((list_marker_minus) @minus)")
local bulletn1_query = vim.treesitter.query.parse("markdown",
    "(list (list_item (list (list_item (list_marker_minus) @nested_minus))))")
local bulletn2_query = vim.treesitter.query.parse("markdown",
    "(list (list_item (list (list_item (list (list_item (list_marker_minus) @nested_minus))))))")

local function refresh_lists(bufnr, mark_ns, tree)
    bufnr = bufnr or 0

    for _, node, _, _ in bullet_query:iter_captures(tree:root(), bufnr) do
        local sl, _, _, ec = node:range()

        local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
        local dash_index = string.find(line, "-")

        if dash_index then
            vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
                { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "●", priority = 0 })
        end
    end

    for _, node, _, _ in bulletn1_query:iter_captures(tree:root(), bufnr) do
        local sl, _, _, ec = node:range()

        local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
        local dash_index = string.find(line, "-")

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
            { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "◐", priority = 10 })
    end

    for _, node, _, _ in bulletn2_query:iter_captures(tree:root(), bufnr) do
        local sl, _, _, ec = node:range()

        local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
        local dash_index = string.find(line, "-")

        vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
            { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "◑", priority = 20 })
    end
end

-- HEADER RENDERING

local header_node_names = {
    "atx_h1_marker", "atx_h2_marker", "atx_h3_marker", "atx_h4_marker",
    "atx_h5_marker", "atx_h6_marker"
}

local header_queries = {}
for _, name in ipairs(header_node_names) do
    local query_str = "((" .. name .. ") @str)"
    table.insert(header_queries, vim.treesitter.query.parse('markdown', query_str))
end

local header_conceal_chars = { "①", "②", "③", "④", "⑤", "⑥" }

local function refresh_header(bufnr, mark_ns, tree)
    bufnr = bufnr or 0

    local sign_colors = {
        "MyMarkupYellow",
        "MyMarkupGreen",
        "MyMarkupPurple",
        "MyMarkupRed",
        "MyMarkupOrange",
        "MyMarkupBlue",
    }

    for i, query in ipairs(header_queries) do
        for _, node, _, _ in query:iter_captures(tree:root(), bufnr) do

            local sl, sc, _, ec = node:range()
            local hl = "MyMarkupHeading" .. i

            vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc, {
                hl_group = hl, end_col = ec, conceal = header_conceal_chars[i],
                sign_text = "⇒", sign_hl_group = sign_colors[i]
            })
        end
    end
end

local function refresh(buf)
    vim.schedule(function()
        local mark_ns = vim.api.nvim_create_namespace('MarkdownRendering')
        vim.api.nvim_buf_clear_namespace(buf, mark_ns, 0, -1)

        local parser = vim.treesitter.get_parser(buf, "markdown")
        assert(parser) -- Throws error anyway but silences lls

        local tree = parser:parse()[1]

        refresh_header(buf, mark_ns, tree)
        refresh_checkbox(buf, mark_ns, tree)
        refresh_blockquote(buf, mark_ns, tree)
        refresh_lists(buf, mark_ns, tree)
    end)
end

local bufnr = vim.api.nvim_get_current_buf()

vim.treesitter.start(bufnr, "markdown")

refresh(bufnr)

vim.api.nvim_create_autocmd({
    "BufEnter", "TextChanged", "TextChangedI", "TextChangedP"
}, {
    buffer = bufnr,
    callback = function(args)
        refresh(args.buf)
    end
})

-- MAPPINGS

vim.keymap.set("n", "<C-p>", function()
    vim.cmd.normal({ args = { "yi(" }, bang = true })
    local link = vim.fn.getreg("\"")
    vim.system({ "firefox", link })
end, { buffer = 0 })
