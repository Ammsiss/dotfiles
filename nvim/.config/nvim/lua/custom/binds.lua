local utils = require("custom.utils")

local default_opts = { noremap = true, silent = true }

local function set(lhs, rhs, mode, opts)
    mode = mode or "n"
    opts = vim.tbl_extend("force", default_opts, opts or {})

    vim.keymap.set(mode, lhs, rhs, opts)
end

set("<F1>", "", "i")

set("<leader>er", "i<Tab><Tab>errExit(\"\");<Esc>hhi")
set("<leader>ii", "i#include \"../lib/tlpi_hdr.h\" // IWYU pragma: export<Esc>\"")

--- Man page macro
set("<leader>;", "/RETURN VALUE<CR>")
set("<leader>p", "/ERROR<CR>")

--- Clear highlight
set("<CR>", function()
    if vim.v.hlsearch == 1 then
        vim.cmd.nohl()
        return ""
    else
        return vim.keycode("<CR>")
    end
end, "n", { expr = true })
set("<Esc>", ":nohlsearch<CR>")

--- Splits
set("<leader>x", ":close<CR>")

set("<M-l>", function() utils.c_cmd("<C-w>4>") end)
set("<M-h>", function() utils.c_cmd("<C-w>4<") end)
set("<M-k>", function() utils.c_cmd("<C-w>2-") end)
set("<M-j>", function() utils.c_cmd("<C-w>2+") end)

set("<leader>v", function()
    vim.cmd("vsp")
    utils.c_cmd("<C-w>L")
end)

set("<c-j>", "<c-w><c-j>")
set("<c-k>", "<c-w><c-k>")
set("<c-l>", "<c-w><c-l>")
set("<c-h>", "<c-w><c-h>")

--- QF list
set("<M-i>", ":cnext<CR>")
set("<M-o>", ":cprev<CR>")
set("<leader>qf", ":lua vim.diagnostic.setqflist()<CR>")

--- Source
set("<leader>l", "<cmd>source %<CR>")

--- Format
set("<leader>qq", function()
    vim.lsp.buf.format({ async = false })
end)

--- Navigation
set("<C-p>", "<C-]>")

set("<C-e>", "j<C-e>")
set("<C-y>", "k<C-y>")

set("<M-e>", "3j3<C-e>")
set("<M-y>", "3k3<C-y>")

set("<leader><leader>", "ci(")

--- Mapping tab breaks <C-I> behaviour!
-- set("<Tab>", function()
--     vim.cmd("tabnext")
-- end)
--
-- set("<S-Tab>", function()
--     vim.cmd("tabprev")
-- end)

local function open_section(word)
    if vim.bo.filetype == "lua" then
        local ok, _ = pcall(function()
            vim.cmd("h " .. word)
        end)
        if not ok then
            print("No help page for " .. word)
        end
    elseif vim.bo.filetype == "c" then
        local man_output = vim.fn.systemlist("man -w " .. word)
        if not man_output[1]:match("No manual entry for") then
            vim.cmd("Man " .. word)
        else
            print("No man entry for '" .. word .. "'")
        end
    else
        print("No information available")
    end
end

set("gK", function()
    local word = vim.fn.expand("<cword>")
    open_section(word)
end)

set("1gK", function()
    local word = "1 " .. vim.fn.expand("<cword>")
    open_section(word)
end)

set("2gK", function()
    local word = "2 " .. vim.fn.expand("<cword>")
    open_section(word)
end)

set("3gK", function()
    local word = "3 " .. vim.fn.expand("<cword>")
    open_section(word)
end)

--- C/C++
set("<leader>b", function()
    vim.cmd("silent! make")

    local qflist = vim.fn.getqflist({ title = 0, items = 1})
    if #qflist.items == 0 then
        vim.cmd("silent! !make run")
    else
        print("Errors in build.\n")
    end
end)

-- Potentially create a root directory marker scanner
set("<leader>sf", function()
    local filename = utils.get_cur_file()

    if string.match(filename, "%.c$") then
        filename = string.gsub(filename, "%.c$", ".h")
    elseif string.match(filename, "%.h$") then
        filename = string.gsub(filename, "%.h$", ".c")
    else
        vim.notify("Not a C file", vim.log.levels.WARN)
        return
    end

    local match = vim.fs.find(filename, {
        limit = 1, type = "file", path = vim.fn.getcwd()
    })

    if match[1] ~= nil then
        vim.cmd("e " .. match[1])
    else
        vim.notify("No match found", vim.log.levels.INFO)
    end
end)
