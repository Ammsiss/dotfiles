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

return M
