-- Stuff for viewing Nexus markdown files

local set = require("custom.utils").set

-- Open a photo in default app
--     Place cursor on a file name that exists under ~/Nexus,
--     then execute this mapping to open the file.
set("<leader>op", function()
    -- File name must be enclosed in [].
    vim.cmd.normal({ args = { "\"pyi[" }, bang = true })

    local file = vim.fn.getreg('p') -- register 'p' for photo

    local open_cmd
    if vim.fn.has("macunix") == 1 then
        open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        open_cmd = "xdg-open"
    end

    local match = vim.fs.find(file, {
        limit = 1, type = "file", path = "~/Nexus"
    })

    if match[1] then
        vim.system({ open_cmd, match[1] }, { detach = true })
    else
        vim.notify("No match found", vim.log.levels.INFO)
    end
end, "n", { desc = "Open a photo in default app" })
