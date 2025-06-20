local utils = require("config.utils")

local default_opts = { noremap = true, silent = true }

local function set(lhs, rhs, mode, opts)
    mode = mode or "n"
    opts = vim.tbl_extend("force", default_opts, opts or {})

    vim.keymap.set(mode, lhs, rhs, opts)
end

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
set("<M-]>", ":cnext<CR>")
set("<M-[>", ":cprev<CR>")
set("<leader>qf", ":lua vim.diagnostic.setqflist()<CR>")

--- Source
set("<leader>l", "<cmd>source %<CR>")

--- Format
set("<leader>qq", function()
    vim.lsp.buf.format({ async = false })
end)

--- Navigation
set("<C-e>", "j<C-e>")
set("<C-y>", "k<C-y>")

set("<M-e>", "3j3<C-e>")
set("<M-y>", "3k3<C-y>")

set("<leader><leader>", "ci(")

--- jump to man page
set("gK", function()
  local word = vim.fn.expand("<cword>")
  --- Check if man page exists
  local man_output = vim.fn.systemlist("man -w " .. word)
  if #man_output > 0 and not man_output[1]:match("No manual entry for") then
    vim.cmd("Man " .. word)
  else
    print("No man entry for " .. word)
  end
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

set("<leader>sf", function()
    local function find_file(dir, filename)
        local path = dir .. "/**/" .. filename
        local found = vim.fn.glob(path, true, false)

        if found ~= "" then
            return found --- Returns full path
        end

        return "" --- Returns empty string if not found
    end

    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    local match

    if filename:match("%.cpp$") then
        match = filename:gsub("%.cpp$", ".h")
    elseif filename:match("%.h$") then
        match = filename:gsub("%.h$", ".cpp")
    else
        print("Not a cpp file")
        return
    end

    local matchPath = find_file(vim.fn.getcwd(), match)
    if matchPath ~= "" then
        vim.cmd("e " .. matchPath)
    else
        print("Not a valid class file")
    end
end)
