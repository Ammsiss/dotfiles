vim.treesitter.start(0, "c")
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
vim.wo[0][0].foldlevel = 99999

local set = require("custom.utils").set

set("<leader>er", "i<Tab><Tab>errExit(\"\");<Esc>hhi")
set("<leader>ii", "i#include \"tlpi_hdr.h\" // IWYU pragma: export<Esc>\"")

