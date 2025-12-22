local M = {}

M.name = "nvim-treesitter/nvim-treesitter"
M.enabled = true
M.build = "TSUpdate"

function M.config()
    require 'nvim-treesitter.configs'.setup {
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "cpp", "bash", "make" },
        auto_install = false,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    }
end

return M
