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

function M.set(lhs, rhs, mode, opts)
    local default_opts = { noremap = true, silent = true }

    mode = mode or "n"
    opts = vim.tbl_extend("force", default_opts, opts or {})

    vim.keymap.set(mode, lhs, rhs, opts)
end

return M
