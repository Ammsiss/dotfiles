local M = {}

M.name = "kylechui/nvim-surround"
M.enabled = true


M.config = function()
    require("nvim-surround").setup({
        aliases = {},
        -- keymaps = {
        --     insert = "<C-g>s",
        --     insert_line = "<C-g>S",
        --     normal = "ys",
        --     normal_cur = "yss",
        --     normal_line = "yS",
        --     normal_cur_line = "ySS",
        --     visual = "S",
        --     visual_line = "gS",
        --     delete = "ds",
        --     change = "cs",
        --     change_line = "cS",
        -- },
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
