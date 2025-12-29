local set = require("custom.utils").set

local buf

set("<leader><leader>s", function()
    buf = vim.api.nvim_get_current_buf()
end)

set("<leader><leader>1", function()
    vim.cmd("b" .. buf)
end)
