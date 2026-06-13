---@type plugin_spec
local M = { slug = "ibhagwan/fzf-lua", enabled = true }

function M.config()
    local fzf = require("fzf-lua")

    fzf.setup({
        winopts = {
            fullscreen = true,
            border = "none",
            ---@diagnostic disable-next-line: missing-fields
            preview = {
                border = "none",
                scrollbar = false,
                ---@diagnostic disable-next-line: missing-fields
                winopts = {
                    number = false
                }
            },
        },
        keymap = {
            builtin = {
                ["<C-u>"] = "preview-page-up",
                ["<C-d>"] = "preview-page-down",
                ["<C-e>"] = "preview-down",
                ["<C-y>"] = "preview-up",
            },
        },
        fzf_opts = {
        },
        fzf_colors = true, -- based
        files = {
            cwd_prompt = false
        }
    })

    local set = require("custom.utils").set

    -- Files
    set("<leader>fd", fzf.files)
    set("<leader>en", function() fzf.files({ cwd = "~/dotfiles" }) end)
    set("<leader>ff", function() fzf.files({ cwd = "~/Nexus" }) end)

    -- Search
    set("<leader>fg", fzf.live_grep)

    -- Git
    set("<leader>fs", fzf.git_status)

    -- Lsp
    set("<leader>fr", fzf.lsp_references)

    -- DAP
    set("<leader>fbc", fzf.dap_commands)
    set("<leader>fbv", fzf.dap_variables)
    set("<leader>fbf", fzf.dap_frames)
    set("<leader>fbs", fzf.dap_frames)

    -- Misc
    set("<leader>fm", fzf.manpages)
    set("<leader>fh", fzf.highlights)
    set("<leader>fk", fzf.keymaps)
    set("<leader>fc", fzf.commands)
    set("<leader>fo", fzf.nvim_options)
end

return M
