vim.opt.formatoptions = "jtcqln"

vim.opt.path = ".,**"

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel = 999 -- So shits not foldy at start

vim.opt.conceallevel = 2
vim.opt.textwidth = 64 -- Width of macos screen with vsp

vim.cmd("highlight @markup.strong.markdown_inline cterm=bold gui=bold guifg=#fe8019")
vim.cmd("highlight @markup.italic.markdown_inline cterm=italic gui=italic guifg=#689d6a")
vim.cmd("highlight @markup.strikethrough.markdown_inline cterm=italic,strikethrough gui=italic,strikethrough guifg=#928374")
vim.cmd("highlight @markup.raw.markdown_inline cterm=bold gui=bold guifg=#83a598 guibg=#302F2F")
vim.cmd("highlight @markup.raw.block.markdown guifg=#b8bb26")

vim.cmd("highlight @markup.link.label.markdown_inline cterm=underline gui=underline guifg=#83a598")

vim.cmd("highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=#fabd2f guibg=#333105")
vim.cmd("highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=#b8bb26 guibg=#12450D")
vim.cmd("highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=#d3869b guibg=#450D3B")
vim.cmd("highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=#83a598 guibg=#0D3E45")

-- SET UP HEADER RENDERING
--
-- TODO
--     1. use parser:register_cbs
--         - parser:register_cbs({ on_changedtree = ... })
--         - register once per buffer (guard with vim.b[bufnr].something = true)
--     2. add a debounce
--         - use vim.uv.new_timer() per buffer
--         - on each TextChanged, stop/start timer; on fire, schedule refresh

local node_names = { "atx_h1_marker", "atx_h2_marker", "atx_h3_marker", "atx_h4_marker" }
local conceal_chars = { "①", "②", "③", "④" }
local highlights = { "MyMarkdownH1", "MyMarkdownH2", "MyMarkdownH3", "MyMarkdownH4" }

for i, hl in ipairs(highlights) do
    local link = "@markup.heading." .. i .. ".markdown"
    vim.api.nvim_set_hl(0, hl, { link = link, })
end

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

    for i, query in ipairs(queries) do
        -- Gather captures for each query
        for _, node, _, _ in query:iter_captures(tree:root(), bufnr) do
            local sl, sc, _, ec = node:range()

            vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc, {
                hl_group = highlights[i], end_col = ec, conceal = conceal_chars[i],
                sign_text = "⇒", sign_hl_group = highlights[i]
            })
        end
    end
end
refresh_header()

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP"  }, {
    buffer = 0,
    callback = function(args)
        vim.schedule(function()
            refresh_header(args.buf) -- Maybe use vim.schedule
        end)
    end,
})

-- Useful binds:
--     gO    - Open up a table of contents with usable links
--     [[/]] - Go to the next or previous header
