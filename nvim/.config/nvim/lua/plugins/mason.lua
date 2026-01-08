---@type plugin_spec
local M = { slug = "mason-org/mason.nvim", enabled = false }

function M.config()
    require("mason").setup()
end

return M
