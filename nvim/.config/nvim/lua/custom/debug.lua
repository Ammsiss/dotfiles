local function find_file(dir, filename)
    if filename == nil then
        return nil
    end

    local path = dir .. "/**/" .. filename
    local found = vim.fn.glob(path, true, false)

    if found ~= "" then
        return found -- Returns full path
    end

    return nil -- Returns empty string if not found
end


local function open(title, command)

    local buf = vim.api.nvim_create_buf(false, true)

    vim.keymap.set("t", "q", "<M-x>", { buffer = buf })
    vim.keymap.set("t", "<M-q>", "q", { noremap = true, buffer = buf})

    local width = vim.o.columns
    local height = vim.o.lines
    local design = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height - 3,
        row = 1,
        col = 0,
        title = title,
        title_pos = "center",
        border = "rounded",
    }

    vim.api.nvim_open_win(buf, true, design)

    vim.fn.jobstart(command, {
            term = true,
            on_exit = function(_, _, _)
                vim.cmd("bd")
            end
        }
    )

end

vim.api.nvim_create_user_command("DB", function(args)

    args.fargs[1] = args.fargs[1] or "main"
    local binary = find_file(vim.fn.getcwd(), args.fargs[1])
    if not binary then
        vim.api.nvim_echo({ { "Failed to find binary!" } }, false, {})
        return
    end

    args.fargs[2] = args.fargs[2] or "b main"

    local break_points = {}
    if args.fargs[2] ~= "b main" then
        local i = 2
        while args.fargs[i] ~= nil do
            table.insert(break_points, args.fargs[i])
        end
    end

    open("LLDB", "lldb " .. binary .. "\n")

    local job_id = vim.b.terminal_job_id
    vim.api.nvim_feedkeys("i", "n", false)
    vim.api.nvim_chan_send(job_id, args.fargs[2] .. "\n")
    vim.api.nvim_chan_send(job_id, "r\n")

    for _, bp in ipairs(break_points) do
        vim.api.nvim_chan_send(job_id, bp)
    end

    vim.defer_fn(function()
        vim.api.nvim_chan_send(job_id, "gui\n")
    end, 1000)

end, { nargs = "*" })
