---@type plugin_spec
local M = {
    slug = "nvim-treesitter/nvim-treesitter",
    build = "TSUpdate"
}

function M.config()
    require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all"
        ensure_installed = {
            "c", "lua", "vim", "vimdoc", "query", "markdown",
            "markdown_inline", "cpp", "bash", "make"
        },
        auto_install = false,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })
end

return M
