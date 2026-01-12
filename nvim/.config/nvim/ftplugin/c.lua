vim.treesitter.start(0, "c")

vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
vim.wo[0][0].foldlevel = 99999

vim.keymap.set("n", "<leader>er", "i<Tab><Tab>errExit(\"\");<Esc>hhi",
    { buffer = 0 })
vim.keymap.set("n", "<leader>ii",
    "i#include \"tlpi_hdr.h\" // IWYU pragma: export<Esc>\"",
    { buffer = 0 })

-- Switch between header and source files
vim.keymap.set("n", "<leader>fs", function()
    local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0))

    if string.match(filename, "%.c$") then
        filename = string.gsub(filename, "%.c$", ".h")
    elseif string.match(filename, "%.h$") then
        filename = string.gsub(filename, "%.h$", ".c")
    else
        vim.notify("Not a C file", vim.log.levels.WARN)
        return
    end

    -- Use vim.fs.root
    -- Look for root dir markers first
    local marker = vim.fs.find("common.mk", {
        upward = true, limit = 1, type = "file"
    })[1]

    local match = vim.fs.find(filename, {
        limit = 1, type = "file",
        path = marker and vim.fs.dirname(marker) or vim.fn.getcwd()
    })[1]

    if match then
        vim.cmd("e " .. match)
    else
        vim.notify("No match found", vim.log.levels.INFO)
    end
end, { buffer = 0 })
