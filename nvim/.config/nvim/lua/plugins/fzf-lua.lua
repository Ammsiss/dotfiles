---@type plugin_spec
local M = { slug = "ibhagwan/fzf-lua", enabled = false }

function M.config()
    require("fzf-lua")
end

return M
