local set = require("custom.utils").set

-- TLPI macros
set("<leader>er", "i<Tab><Tab>errExit(\"\");<Esc>hhi")

vim.opt.cindent = true
set("<leader>ii", "i#include \"tlpi_hdr.h\" // IWYU pragma: export<Esc>\"")
