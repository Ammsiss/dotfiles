vim.api.nvim_create_user_command("Anki", function()

    local buf = vim.api.nvim_create_buf(false, true)
    vim.treesitter.start(buf, "markdown")
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    local output = {}
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

    local width = math.floor(vim.o.columns * 0.7)
    local height = math.floor(vim.o.lines * 0.7)

    local design = {
        style = "minimal",
        relative = "editor",
        height = height,
        width = width,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        border = "rounded",
    }

    -- open the floating window
    vim.api.nvim_open_win(buf, true, design)

end, { desc = "Launch flash card script" })
