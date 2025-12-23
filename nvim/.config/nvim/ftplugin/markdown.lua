vim.opt.formatoptions = "jtcqln"

vim.opt.path = ".,**"

vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel = 999 -- So shits not foldy at start

vim.opt.conceallevel = 3
vim.opt.textwidth = 64 -- Width of macos screen with vsp

vim.cmd("highlight @markup.strong.markdown_inline cterm=bold gui=bold guifg=#689d6a")
vim.cmd("highlight @markup.italic.markdown_inline cterm=italic gui=italic guifg=#689d6a")
vim.cmd("highlight @markup.strikethrough.markdown_inline cterm=italic,strikethrough gui=italic,strikethrough guifg=#928374")
vim.cmd("highlight @markup.raw.markdown_inline guifg=#83a598 guibg=#302F2F")

vim.cmd("highlight @markup.heading.1.markdown cterm=bold gui=bold,underline guifg=#fabd2f")
vim.cmd("highlight @markup.heading.2.markdown cterm=bold gui=bold,underline guifg=#b8bb26")
vim.cmd("highlight @markup.heading.3.markdown cterm=bold gui=bold,underline guifg=#d3869b")
vim.cmd("highlight @markup.heading.4.markdown cterm=bold gui=bold,underline guifg=#83a598")

-- See treesitter.txt

-- Useful binds:
--     gO    - Open up a table of contents with usable links
--     [[/]] - Go to the next or previous header
