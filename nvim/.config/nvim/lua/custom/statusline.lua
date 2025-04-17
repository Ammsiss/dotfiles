function G_CURRENT_MODE()
    local mode_map = {
        n = "N",
        i = "I",
        v = "V",
        V = "V-L",
        [""] = "V-B",
        c = "C",
        R = "R",
        t = "TERMINATOR",
    }

    local mode = vim.api.nvim_get_mode().mode
    return mode_map[mode] or mode
end

local devicons = require("nvim-web-devicons")
function G_CURRENT_FT()
    local ft = vim.bo.filetype
    local fname = vim.api.nvim_buf_get_name(0)
    local icon, _ = devicons.get_icon(fname, nil, { default = true })
    return (icon .. " " .. ft) or ""
end

vim.opt.statusline = "%#StatusLineFilename#%<%{v:lua.G_CURRENT_MODE()}%* %f%m%=%{v:lua.G_CURRENT_FT()} %l/%L %v/%c"
