local M = {}

function M.c_cmd(cmd)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
            cmd, true, false, true
        ),
        "n",
        true
    )
end

function M.get_temp()
    local temp_dir = vim.fn.stdpath("data") .. "/temp"
    if vim.fn.isdirectory(temp_dir) == 0 then
        vim.fn.mkdir(temp_dir, "p")
    end

    return temp_dir .. "/temp-" .. vim.fn.getpid() .. ".txt"
end

return M
