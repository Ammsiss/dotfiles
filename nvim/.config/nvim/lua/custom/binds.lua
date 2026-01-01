local utils = require("custom.utils")
local set = utils.set

set("<leader>d", function()
    vim.diagnostic.open_float(nil, { scope = "cursor", source = true })
end)

-- fat finger this with moonlander
set("<F1>", "", "i")

-- Return clears hl if its on
set("<CR>", function()
    if vim.v.hlsearch == 1 then
        vim.cmd.nohl()
        return ""
    else
        return vim.keycode("<CR>")
    end
end, "n", { expr = true })
set("<Esc>", ":nohlsearch<CR>")

-- 'q' closes splits, help, man. This also has the added
-- bonus of making 'q:' hard to mistype.
set("q", ":close<CR>")
set("<leader>q", "q", "n", { noremap = true })

-- No option key use. Yay!
local function make_split_num(num, cmd)
    return function()
        if num == 0 then
            num = ""
        end
        utils.feedkeys("<C-w>" .. num .. cmd)
    end
end
for num = 0, 9 do
    local lhs = "<leader>"
    if num ~= 0 then
        lhs = lhs .. num
    end
    set(lhs .. "h", make_split_num(num * 2, "<"))
    set(lhs .. "j", make_split_num(num * 2, "-"))
    set(lhs .. "k", make_split_num(num * 2, "+"))
    set(lhs .. "l", make_split_num(num * 2, ">"))
end

-- Easier split naviagtion
set("<c-j>", "<c-w><c-j>")
set("<c-k>", "<c-w><c-k>")
set("<c-l>", "<c-w><c-l>")
set("<c-h>", "<c-w><c-h>")

-- QF list
set("<M-i>", ":cnext<CR>")
set("<M-o>", ":cprev<CR>")
set("<leader>fq", ":lua vim.diagnostic.setqflist()<CR>")

-- Because ']' on moonlander is awkward
set("<C-p>", function()
    utils.feedkeys("<C-]>")
end)

-- So cursor is not left behind
set("<C-e>", "j<C-e>")
set("<C-y>", "k<C-y>")

-- Detects filetype and opens appropriate doc page
local function open_docs(word)
    local ft = vim.bo.filetype
    if ft == "lua" or ft == "help" then
        local ok, _ = pcall(function()
            vim.cmd("h " .. word)
        end)
        if not ok then
            vim.notify("No help page for " .. word,
                vim.log.levels.INFO)
        end
    else
        local ok, _ = pcall(function()
            vim.cmd("Man " .. word)
        end)
        if not ok then
            vim.notify("No manual entry for " .. word,
                vim.log.levels.INFO)
        end
    end
end

-- Binds for opening specific man page sections
local function make_open_sect(sect)
    return function()
        local word = vim.fn.expand("<cword>")
        if sect then
            word = sect .. " " .. word
        end
        open_docs(word)
    end
end
set("gK", make_open_sect())
for sect = 1, 9 do
    set(sect .. "gK", make_open_sect(sect))
end

-- Jump to important sections
set("<leader>;", "/RETURN VALUE<CR>")
set("<leader>p", "/ERROR<CR>")

-- Bind for running Makefile
set("<leader>b", function()
    vim.cmd("silent! make")

    local qflist = vim.fn.getqflist({ title = 0, items = 1})
    if #qflist.items == 0 then
        vim.cmd("silent! !make run")
    else
        print("Errors in build.\n")
    end
end)

-- Switch between header and source files
set("<leader>sf", function()
    local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0))

    if string.match(filename, "%.c$") then
        filename = string.gsub(filename, "%.c$", ".h")
    elseif string.match(filename, "%.h$") then
        filename = string.gsub(filename, "%.h$", ".c")
    else
        vim.notify("Not a C file", vim.log.levels.WARN)
        return
    end

    -- Use vim.fs.root
    -- Look for root dir markers first
    local marker = vim.fs.find("common.mk", {
        upward = true, limit = 1, type = "file"
    })[1]

    local match = vim.fs.find(filename, {
        limit = 1, type = "file",
        path = marker and vim.fs.dirname(marker) or vim.fn.getcwd()
    })[1]

    if match then
        vim.cmd("e " .. match)
    else
        vim.notify("No match found", vim.log.levels.INFO)
    end
end)

-- Search tlpi-dist repo for a file
set("<leader>tl", function()
    local file = vim.fn.expand("<cfile>")

    local match = vim.fs.find(file, {
        limit = 1, type = "file",
        path = "~/Projects/TLPI_Exercises"
    })[1]

    if match then
        vim.cmd("e " .. match)
    end
end)
