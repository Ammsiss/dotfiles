local userCmd = vim.api.nvim_create_augroup("user", { clear = true })

vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
        end
    end,
    group = userCmd,
    desc = "Enter terminal mode on terminal split entry"
})

-- HOT FIX FOR GLOBAL WINBORDER OPTION
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopeFindPre",
  callback = function()
    vim.opt_local.winborder = "none"
    vim.api.nvim_create_autocmd("WinLeave", {
      once = true,
      callback = function()
        vim.opt_local.winborder = "rounded"
      end,
    })
  end,
})
-- vim.api.nvim_create_autocmd("BufDelete", {
--     callback = function(args)
--         print("Bye bye buffer #" .. args.buf)
--     end,
--     group = userCmd,
--     desc = "Prints a message on buffer deletion",
-- })
--
-- vim.api.nvim_create_autocmd("LspAttach", {
--     callback = function()
--         vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
--             border = "rounded",
--         })
--
--         vim.diagnostic.config({
--             float = { border = "rounded" },
--         })
--     end,
--     group = userCmd,
--     desc = "Apply rounded borders to LSP floating windows"
-- })
