--- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
--- Tab
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
--- Indent
vim.opt.cindent = true
vim.opt.autoindent = true
vim.opt.shiftround = true
--- Search
vim.opt.scrolloff = 3
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.wrapscan = false
--- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 999
--- Misc
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "-" }
vim.opt.wrap = true
vim.opt.pumheight = 10
vim.opt.showmode = false
vim.opt.winborder = "rounded"

--- Diagnostic settings
vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = ">",
            [vim.diagnostic.severity.WARN]  = "?",
            [vim.diagnostic.severity.HINT]  = "!",
            [vim.diagnostic.severity.INFO]  = "i",
        },
    },
    underline = true,
    update_in_insert = false,
})
