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

vim.cmd("highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=#fabd2f guibg=#333105")
vim.cmd("highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=#b8bb26 guibg=#12450D")
vim.cmd("highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=#d3869b guibg=#450D3B")
vim.cmd("highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=#83a598 guibg=#0D3E45")

-- Set up header rendering

local mark_ns = vim.api.nvim_create_namespace('MarkdownRendering')

vim.api.nvim_set_hl(0, "MyMarkdownH1", { link = "@markup.heading.1.markdown", })
vim.api.nvim_set_hl(0, "MyMarkdownH2", { link = "@markup.heading.2.markdown", })
vim.api.nvim_set_hl(0, "MyMarkdownH3", { link = "@markup.heading.3.markdown", })
vim.api.nvim_set_hl(0, "MyMarkdownH4", { link = "@markup.heading.4.markdown", })

local mark_list = {}

local function refresh_header()
    local h1_query = vim.treesitter.query.parse('markdown', [[
        ((atx_h1_marker) @str)
    ]])
    local h2_query = vim.treesitter.query.parse('markdown', [[
        ((atx_h2_marker) @str)
    ]])
    local h3_query = vim.treesitter.query.parse('markdown', [[
        ((atx_h3_marker) @str)
    ]])
    local h4_query = vim.treesitter.query.parse('markdown', [[
        ((atx_h4_marker) @str)
    ]])

    local tree = vim.treesitter.get_parser():parse()[1]

    for _, node, _ in h1_query:iter_captures(tree:root(), 0) do
            -- sc er ec
        local sr, sc, _, ec = node:range()

        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, {
            hl_group = "MyMarkdownH1", end_col = ec, conceal = "①",
            sign_text = "⇒", sign_hl_group = "MyMarkdownH1"
        }))
        -- local type = node:type()
        -- local text = vim.treesitter.get_node_text(node, 0)
    end

    for _, node, _ in h2_query:iter_captures(tree:root(), 0) do
        local sr, sc, _, ec = node:range()

        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, {
            hl_group = "MyMarkdownH2", end_col = ec, conceal = "②",
            sign_text = "⇒", sign_hl_group = "MyMarkdownH2"
        }))
        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, 0, {
            virt_text = { { " ", "MyMarkdownH2" } },
            virt_text_pos = "inline",
        }))
    end

    for _, node, _ in h3_query:iter_captures(tree:root(), 0) do
        local sr, sc, _, ec = node:range()

        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, {
            hl_group = "MyMarkdownH3", end_col = ec, conceal = "③",
            sign_text = "⇒", sign_hl_group = "MyMarkdownH3"
        }))
        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, 0, {
            virt_text = { { "  ", "MyMarkdownH3" } },
            virt_text_pos = "inline",
        }))
    end

    for _, node, _ in h4_query:iter_captures(tree:root(), 0) do
        local sr, sc, _, ec = node:range()

        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, {
            hl_group = "MyMarkdownH4", end_col = ec, conceal = "④",
            sign_text = "⇒", sign_hl_group = "MyMarkdownH4"
        }))
        table.insert(mark_list, vim.api.nvim_buf_set_extmark(0, mark_ns, sr, 0, {
            virt_text = { { "   ", "MyMarkdownH4" } },
            virt_text_pos = "inline",
        }))
    end
end
refresh_header()

local function delete_marks()
    for _, mark in ipairs(mark_list) do
        vim.api.nvim_buf_del_extmark(0, mark_ns, mark)
    end
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP"  }, {
  buffer = 0,
  callback = function()
      delete_marks()
      refresh_header()
  end,
})

-- vim.print(vim.api.nvim_buf_get_extmarks(0, MARK_NS, 0, -1, {}))

-- Useful binds:
--     gO    - Open up a table of contents with usable links
--     [[/]] - Go to the next or previous header
