---@type plugin_spec
local M = {
    slug = "nvim-treesitter/nvim-treesitter",
    build = "TSUpdate"
}

function M.config()
    local treesitter = require("nvim-treesitter")
    treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site"
    })
    treesitter.install({
        "c", "lua", "vim", "vimdoc", "query", "markdown",
        "markdown_inline", "cpp", "zsh", "make", "json",
        "yaml", "toml"
    })
end

return M
