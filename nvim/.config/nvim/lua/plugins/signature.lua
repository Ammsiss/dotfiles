local M = {}

M.name = "ray-x/lsp_signature.nvim"
M.enabled = true

function M.config()
    require("lsp_signature").setup({
        bind = true,
        handler_opts = {
            border = "rounded"
        },
        always_trigger = false,
        floating_window = false,
        hint_enable = false,
        toggle_key = "<M-h>",           -- Show signature help
        select_signature_key = "<C-n>", -- Next function overload
        move_cursor_key = "<C-p>"       -- Previous function overload
    })
end

return M
