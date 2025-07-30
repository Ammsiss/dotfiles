vim.api.nvim_create_user_command("PrintTruth", function(args)
    print("Junji is " .. (args.fargs[1] or "cool!"))
end, { nargs = "?" })

vim.api.nvim_create_user_command("LoadC", function()
    vim.cmd("args **/*.cpp **/*.h")
    vim.cmd("argdo edit")
end, {})

vim.api.nvim_create_user_command("Grep", function(args)
    if args.fargs[1] == nil then
        print("Must enter search term")
        return
    end

    local cmd = {
        "rg", "-F", "--vimgrep", "--hidden", "--line-number", "--smart-case", args.fargs[1]
    }

    local on_exit = function(obj)

        local data = {}
        local field_names = { "filename", "lnum", "col", "text" }

        local lines = vim.split(obj.stdout, "\n", { trimempty = true })
        for _, line in ipairs(lines) do
            local i = 1
            local entry = {}
            for field in line:gmatch("([^:]+)") do
                entry[field_names[i]] = field
                if i == 4 then
                    break
                end
                i = i + 1
            end
            table.insert(data, entry)
        end

        vim.schedule(function()
            vim.fn.setqflist(data)
            vim.cmd("cfirst")
        end)
    end

    vim.system(cmd, { text = true }, on_exit)
end, { nargs = "?" })
