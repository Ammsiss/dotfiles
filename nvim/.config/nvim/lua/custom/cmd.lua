vim.api.nvim_create_user_command("PrintTruth", function(args)
    print("Junji is " .. (args.fargs[1] or "cool!"))
end, { nargs = "?" })

vim.api.nvim_create_user_command("LoadC", function()
    vim.cmd("args **/*.cpp **/*.h")
    vim.cmd("argdo edit")
end, {})

