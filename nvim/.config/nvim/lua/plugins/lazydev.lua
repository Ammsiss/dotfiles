---@type plugin_spec
local M = { slug = "folke/lazydev.nvim" }

M.config = function()
    local opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    }

    require("lazydev").setup(opts)
end

return M
