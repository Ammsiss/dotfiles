local bufnr
local win
local open

vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
        if tonumber(args.match) == win then
            open = false
        end
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    callback = function()
        bufnr = nil
    end,
    buffer = bufnr
})

local function open_term_win()
    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.7)

    local float_design = {
        style = "minimal",
        relative = "editor",
        height = height,
        width = width,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        border = "rounded",
    }

    win = vim.api.nvim_open_win(bufnr, true, float_design)
    if win == 0 then
        vim.notify("nvim_open_win: Failed to open win",
            vim.log.levels.WARN)
    end
    open = true

    vim.cmd("e " .. vim.fn.tempname() .. ".lua")
end

vim.api.nvim_create_user_command("LuaScratch", function()
    if not bufnr then
        bufnr = vim.api.nvim_create_buf(false, false)
        vim.bo[bufnr].swapfile = false
        vim.bo[bufnr].bufhidden = "hide"
    end

    if not open then
        open_term_win()
    end
end, { desc = "Open a lua scratch pad" })
