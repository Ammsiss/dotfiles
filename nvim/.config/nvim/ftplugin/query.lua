local set = require("custom.utils").set

set("<leader>d", function()
    vim.diagnostic.open_float()
end)
