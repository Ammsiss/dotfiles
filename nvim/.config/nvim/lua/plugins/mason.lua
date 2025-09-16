local M = {}

M.name = "mason-org/mason.nvim"
M.enabled = true

function M.config()
    require("mason").setup()
end

return M
