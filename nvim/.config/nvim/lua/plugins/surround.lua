---@type plugin_spec
local M = { slug = "kylechui/nvim-surround", enabled = false }

M.config = function()
    require("nvim-surround").setup({
        aliases = {
            ["a"] = ">",
            ["b"] = "**",
            ["B"] = "}",
            ["r"] = "]",
            ["q"] = { '"', "'", "`" },
            ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
    })
end

return M
