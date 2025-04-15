local function open(title, command)

    local buf = vim.api.nvim_create_buf(false, true)

    local width = vim.o.columns - 20
    local height = vim.o.lines - 6 - 3
    local design = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2 - 2,
        col = (vim.o.columns - width) / 2,
        title = title,
        title_pos = "center",
        border = "rounded",
    }

    vim.api.nvim_open_win(buf, true, design)

    vim.fn.jobstart(command, {
            term = true,
            on_exit = function(_, _, _)
                vim.cmd("bd")
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
end

vim.keymap.set("n", "<leader>lg", function()
    open(" Lazy Git ", "lazygit --use-config-file ~/.config/lazygit/config.yml")
end, { noremap = true, silent = true })
