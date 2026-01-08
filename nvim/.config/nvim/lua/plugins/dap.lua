---@type plugin_spec
local M = { slug = "mfussenegger/nvim-dap" }

local map_desc = "DAP"

local function del_keymaps_by_desc()
  for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
    if map.desc == map_desc then
      vim.keymap.del("n", map.lhs)
    end
  end
end

M.config = function()
    local dap = require("dap")

    dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
    }

    dap.configurations.c = {{
            name = "Launch",
            type = "gdb",
            request = "launch",
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            args = {}, -- provide arguments if needed
            cwd = "${workspaceFolder}",
            stopAtBeginningOfMainSubprogram = false,
        }, {
            name = "Select and attach to process",
            type = "gdb",
            request = "attach",
            program = function()
                return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            pid = function()
                local name = vim.fn.input('Executable name (filter): ')
                return require("dap.utils").pick_process({ filter = name })
            end,
            cwd = '${workspaceFolder}'
        }
    }

    vim.keymap.set('n', '<leader>db', function() dap.continue() end)
    vim.keymap.set('n', '<leader>rl', function() dap.run_last() end)
    vim.keymap.set('n', '<leader>bb', function() dap.toggle_breakpoint() end)

    local widgets = require('dap.ui.widgets')

    local sidebar = nil
    local centered_float = nil
    local preview = nil

    dap.listeners.on_session["dap-binds-plug"] = function(_, new)
        if new then
            vim.keymap.set('n', 'c', function() dap.continue() end, { desc = map_desc })
            vim.keymap.set('n', 'd', function() dap.step_over() end, { desc = map_desc })
            vim.keymap.set('n', 's', function() dap.step_into() end, { desc = map_desc })
            vim.keymap.set('n', 'S', function() dap.step_out() end, { desc = map_desc })
            vim.keymap.set('n', 'r', function() dap.repl.open() end, { desc = map_desc })
            vim.keymap.set('n', 'gK', function() widgets.hover() end, { desc = map_desc })

            vim.keymap.set('n', 'p', function()
                if not preview then
                    preview = widgets.preview()
                end
                preview.toggle()
            end, { desc = map_desc })

            vim.keymap.set('n', 'f', function()
                if not centered_float then
                    centered_float = widgets.centered_float(widgets.frames)
                end
                    centered_float.toggle()
            end, { desc = map_desc })

            vim.keymap.set('n', 'x', function()
                if not sidebar then
                    sidebar = widgets.sidebar(widgets.scopes)
                end
                sidebar.toggle()
            end, { desc = map_desc })
        else
            del_keymaps_by_desc()
        end
    end
end

return M
