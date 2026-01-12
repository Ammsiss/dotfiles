---@type plugin_spec
return {
    slug = "jbyuki/one-small-step-for-vimkind",
    priority = -100,
    config = function()
        local dap = require("dap")

        vim.keymap.set('n', '<leader>osv', function()
            require("osv").launch({ port = 8086 })
        end)

        dap.configurations.lua = {{
            type = 'nlua',
            request = 'attach',
            name = "Attach to running Neovim instance",
        }}

        dap.adapters.nlua = function(callback, config)
            callback({
                type = 'server',
                host = config.host or "127.0.0.1",
                port = config.port or 8086
            })
        end
    end
}
