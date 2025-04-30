local set = vim.keymap.set
local opts = { noremap = true, silent = true }

--- Clear highlight
set("n", "<CR>", function()
    if vim.v.hlsearch == 1 then
        vim.cmd.nohl()
        return ""
    else
        return vim.keycode("<CR>")
    end
end, { expr = true })
set("n", "<Esc>", ":nohlsearch<CR>", opts)

--- Export lsp diagnostic to qflist
set("n", "<leader>qf", ":lua vim.diagnostic.setqflist()<CR>", opts)

--- Split
set("n", "<M-,>", "<c-w>5<", opts)
set("n", "<M-.>", "<c-w>5>", opts)
set("n", "<M-d>", "<C-W>+", opts)
set("n", "<M-s>", "<C-W>-", opts)

set("n", "<c-j>", "<c-w><c-j>", opts)
set("n", "<c-k>", "<c-w><c-k>", opts)
set("n", "<c-l>", "<c-w><c-l>", opts)
set("n", "<c-h>", "<c-w><c-h>", opts)

--- QF list
set("n", "<M-]>", ":cnext<CR>", opts)
set("n", "<M-[>", ":cprev<CR>", opts)

--- Source
set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

--- Format
set("n", "<leader>qq", function()
    vim.lsp.buf.format({ async = false })
end, opts)

--- Tabs
set("n", "<M-t>", ":tabnew<CR>", opts)
set("n", "<M-1>", "1gt", opts)
set("n", "<M-2>", "2gt", opts)
set("n", "<M-3>", "3gt", opts)
set("n", "<M-4>", "4gt", opts)
set("n", "<M-5>", "5gt", opts)


--- Misc
set("n", "<C-e>", "j<C-e>", opts)
set("n", "<C-y>", "k<C-y>", opts)

set("n", "<M-e>", "3j3<C-e>", opts)
set("n", "<M-y>", "3k3<C-y>", opts)

set("n", "<leader>x", ":close<CR>", opts)

-- Jump to matching class file
set("n", "<leader>sf", function()
    local function find_file(dir, filename)
        local path = dir .. "/**/" .. filename
        local found = vim.fn.glob(path, true, false)

        if found ~= "" then
            return found -- Returns full path
        end

        return "" -- Returns empty string if not found
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

-- jump to man page
vim.keymap.set('n', 'gK', function()
  local word = vim.fn.expand('<cword>')
  -- Check if man page exists
  local man_output = vim.fn.systemlist('man -w ' .. word)
  if #man_output > 0 and not man_output[1]:match('No manual entry for') then
    vim.cmd('Man ' .. word)
  else
    print('No man entry for ' .. word)
  end
end)

-- set("n", "<leader>br", function()
--     local filename = vim.fn.input("Enter filename: ")
--     local path = vim.fn.systemlist("find . -type f -iname " .. vim.fn.shellescape(filename))
--     if #path == 0 then
--         print("File not found")
--         return
--     end
--     vim.cmd("belowright split " .. path[1])
-- end, opts)
--
-- set("n", "<leader>rv", function()
--     local filename = vim.fn.input("Enter filename: ")
--     local path = vim.fn.systemlist("find . -type f -iname " .. vim.fn.shellescape(filename))
--     if #path == 0 then
--         print("File not found")
--         return
--     end
--     vim.cmd("belowright vsplit " .. path[1])
-- end, opts)
