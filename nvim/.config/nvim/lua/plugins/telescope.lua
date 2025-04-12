local M = {}

M.name = "nvim-telescope/telescope.nvim"
M.enabled = true

M.expects = {
    "nvim-lua/plenary.nvim",
}

function M.config()
    local set = vim.keymap.set
    local opts = { noremap = true, silent = true }

    local builtin = require('telescope.builtin')
    local themes = require('telescope.themes')

    local layout = { layout_config = { height = 0.8 } }
    local theme = "get_ivy"

    set("n", "<leader>fd", function()
        builtin.find_files(themes[theme](layout))
    end, opts)
    set("n", "<leader>fg", function()
        builtin.live_grep(themes[theme](layout))
    end, opts)
    set("n", "<leader>fb", function()
        builtin.buffers(themes[theme](layout))
    end, opts)
    set("n", "<leader>fh", function()
        builtin.help_tags(themes[theme](layout))
    end, opts)
    set("n", "<leader>fr", function()
        builtin.lsp_references(themes[theme](layout))
    end, opts)
    set("n", "<leader>en", function()
        builtin.find_files(themes[theme]({ layout_config = { height = 0.8 }, cwd = vim.fn.stdpath("config") }))
    end, opts)
    set("n", "<leader>fe", function()
        builtin.diagnostics(themes[theme](layout))
    end, opts)
    set("n", "<leader>fs", function()
        builtin.git_status(themes[theme](layout))
    end, opts)
    set("n", "<leader>fc", function()
        builtin.man_pages(themes[theme](layout))
    end, opts)

    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#E67E22", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#E67E22", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#E67E22", bg = "NONE" })
end

return M
