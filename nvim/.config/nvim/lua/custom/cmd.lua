vim.api.nvim_create_user_command("LoadC", function()
    vim.cmd("args **/*.cpp **/*.h")
    vim.cmd("argdo edit")
end, {})
