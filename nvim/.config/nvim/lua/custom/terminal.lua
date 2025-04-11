local terminals = {}

local function spawn_terminal()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
    vim.api.nvim_feedkeys("i", "n", false)

    local bufnr = vim.api.nvim_get_current_buf()
    terminals[bufnr] = true

    vim.api.nvim_create_autocmd("BufDelete", {
        buffer = bufnr,
        callback = function()
            terminals[bufnr] = nil
        end,
    })

    return bufnr
end

local function term_loaded_open()
    for bufnr, _ in pairs(terminals) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local win_list = vim.api.nvim_list_wins()
            for _, win in ipairs(win_list) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    return win
                end
            end
        end
    end

    return false
end

vim.keymap.set("n", "<leader>b", function()
    vim.cmd("silent! make")

    local qflist = vim.fn.getqflist({ title = 0, items = 1})
    if #qflist.items == 0 then
        vim.cmd("silent! !make run")
    else
        print("Errors in build.\n")
    end
end)

vim.keymap.set("n", "<leader><leader>b", function()
    local win = term_loaded_open()
    if win then
        vim.api.nvim_set_current_win(win)
    else
        spawn_terminal()
    end

    local job_id = vim.b.terminal_job_id
    vim.api.nvim_chan_send(job_id, "make && make run\n")
end)

vim.keymap.set("n", "<leader>st", function()
    if term_loaded_open() then
        print("Terminal already open!")
        return
    end

    local bufnr = spawn_terminal()
    print("Opened Terminal #" .. bufnr)
end)

vim.keymap.set("n", "<M-l>", function()
    local win = term_loaded_open()
    if win then
        vim.api.nvim_set_current_win(win)
        vim.cmd("hide")
        return
    end

    local buffers = {}
    for b in pairs(terminals) do
        table.insert(buffers, b)
    end

    table.sort(buffers, function(a, b) return a > b end)

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.cmd.vnew()
            vim.cmd("b" .. bufnr)
            vim.cmd.wincmd("J")
            vim.api.nvim_win_set_height(0, 15)
            vim.api.nvim_feedkeys("i", "n", false)
            print("Opened Termianl #" .. bufnr)
            return
        else
            terminals[bufnr] = nil
        end
    end
    print("No terminals loaded")
end)

vim.keymap.set("t", "<M-c>", function()
    local buffers = {}
    for b in pairs(terminals) do
        table.insert(buffers, b)
    end

    table.sort(buffers, function(a, b) return a > b end)

    local currentOpen
    for bufnr, _ in pairs(terminals) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local win_list = vim.api.nvim_list_wins()
            for _, win in ipairs(win_list) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    currentOpen = bufnr
                end
            end
        end
    end

    if currentOpen == nil then
        return
    end

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) and bufnr < currentOpen then
            vim.cmd("b" .. bufnr)
            print("Opened Termianl #" .. bufnr)
            return
        end
    end
    print("Start of list")
end)

vim.keymap.set("t", "<M-v>", function()
    local buffers = {}
    for b in pairs(terminals) do
        table.insert(buffers, b)
    end

    table.sort(buffers, function(a, b) return a < b end)

    local currentOpen
    for bufnr, _ in pairs(terminals) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            local win_list = vim.api.nvim_list_wins()
            for _, win in ipairs(win_list) do
                if vim.api.nvim_win_get_buf(win) == bufnr then
                    currentOpen = bufnr
                end
            end
        end
    end

    if currentOpen == nil then
        print("Current terminal not found")
        return
    end

    for _, bufnr in ipairs(buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) and bufnr > currentOpen then
            vim.cmd("b" .. bufnr)
            print("Opened Termianl #" .. bufnr)
            return
        end
    end
    print("End of list")
end)

vim.keymap.set("t", "<M-l>", "<C-\\><C-n>:hide<CR>", { silent = true })

-- Make it so other windows layout doesn't change when toggling terminal
-- Add multi terminal splits in terminal display
