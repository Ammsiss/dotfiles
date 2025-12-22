vim.opt.conceallevel = 3
vim.opt.textwidth = 70
vim.opt.formatoptions = "twan"

vim.cmd("highlight @markup.strong guifg=#FF8E00")
vim.cmd("highlight @markup.italic.markdown_inline guifg=#cc241d")

-- vim.cmd("highlight @markup.heading.1.markdown guifg=GruvboxBlue")
-- vim.cmd("highlight @markup.heading.2.markdown guifg=#FF8E00")

-- Make bold
vim.keymap.set('v', '<C-b>', function()
    print("hello")
end, { buffer = 0, silent = true, desc = 'bold word' })
