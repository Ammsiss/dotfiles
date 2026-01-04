vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "json",
    callback = function(opts)
        vim.treesitter.start(opts.buf, "json")
    end
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "toml",
    callback = function(opts)
        vim.treesitter.start(opts.buf, "toml")
    end
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "yaml",
    callback = function(opts)
        vim.treesitter.start(opts.buf, "yaml")
    end
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "zsh",
    callback = function(opts)
        vim.treesitter.start(opts.buf, "zsh")
    end
})
