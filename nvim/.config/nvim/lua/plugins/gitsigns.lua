local M = {}

M.name = "lewis6991/gitsigns.nvim"
M.enabled = true

function M.config()
    local signs = require("gitsigns")
    signs.setup()

    vim.keymap.set('n', '<leader>hr', signs.reset_hunk)
    vim.keymap.set('n', '<leader>ts', function() vim.cmd("Gitsigns toggle_signs") end)

    vim.keymap.set("n", "<leader>gi", ":Gitsigns preview_hunk<CR>", { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>gn", function()
        vim.cmd(":Gitsigns nav_hunk next")
        vim.cmd(":Gitsigns preview_hunk")
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>gp", function()
        vim.cmd(":Gitsigns nav_hunk prev")
        vim.cmd(":Gitsigns preview_hunk")
    end, { noremap = true, silent = true })

    vim.keymap.set("n", "<leader>gt", function()
        signs.toggle_signs()
    end, { noremap = true, silent = true })
end

return M
