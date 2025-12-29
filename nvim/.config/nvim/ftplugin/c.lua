local set = require("custom.utils").set

vim.opt.cindent = true

-- TLPI macros
set("<leader>er", "i<Tab><Tab>errExit(\"\");<Esc>hhi")
set("<leader>ii", "i#include \"tlpi_hdr.h\" // IWYU pragma: export<Esc>\"")
