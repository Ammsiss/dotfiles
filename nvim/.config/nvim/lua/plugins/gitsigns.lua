---@type plugin_spec
local M = { slug = "lewis6991/gitsigns.nvim" }

function M.config()
    local signs = require("gitsigns")
    signs.setup({
        signs = {
            add          = { text = '+' },
            change       = { text = '+' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        signs_staged = {
            add          = { text = '+' },
            change       = { text = '+' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        on_attach = function(bufnr)
            vim.keymap.set('n', '<leader>hr', signs.reset_hunk,
                { desc = "Gitsigns->reset_hunk()", buffer = bufnr })
            vim.keymap.set('n', '<leader>hR', signs.reset_buffer,
                { desc = "Gitsigns->reset_buffer()", buffer = bufnr })

            vim.keymap.set('n', '<leader>hs', signs.stage_hunk,
                { desc = "Gitsigns->stage_hunk()", buffer = bufnr })
            vim.keymap.set('n', '<leader>hS', signs.stage_buffer,
                { desc = "Gitsigns->stage_buffer()", buffer = bufnr })

            vim.keymap.set("n", "<leader>hp", signs.preview_hunk,
                { desc = "Gitsigns->preview_hunk()", buffer = bufnr })
            vim.keymap.set("n", "<leader>hi", signs.preview_hunk_inline,
                { desc = "Gitsigns->preview_hunk_inline()", buffer = bufnr })

            vim.keymap.set("n", "<leader>hts", signs.toggle_signs,
                { desc = "Gitsigns->toggle_signs()", buffer = bufnr })
            vim.keymap.set("n", "<leader>htb", signs.toggle_current_line_blame,
                { desc = "Gitsigns->toggle_current_line_blame()", buffer = bufnr })
            vim.keymap.set("n", "<leader>htw", signs.toggle_word_diff,
                { desc = "Gitsigns->toggle_word_diff()", buffer = bufnr })
        end
    })

    local gb = require("custom.color").gruvbox
    vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { fg = gb.dark0, bg = gb.bright_red })
    vim.api.nvim_set_hl(0, "GitSignsAddInline", { fg = gb.dark0, bg = gb.bright_green })
    vim.api.nvim_set_hl(0, "GitSignsChangeInline", { fg = gb.dark0, bg = gb.bright_green })
end

return M
