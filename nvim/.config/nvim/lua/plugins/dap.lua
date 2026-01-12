---@type plugin_spec
local M = { slug = "mfussenegger/nvim-dap" }

local utils = require("custom.utils")

M.config = function()
    local dap = require("dap")
    local dap_utils = require("dap.utils")

    vim.cmd("au FileType dap-repl lua require('dap.ext.autocompl').attach()")

    vim.fn.sign_define('DapBreakpoint', {
        text = '●', texthl = 'GruvboxRed', linehl = '', numhl = ''
    })
    vim.fn.sign_define('DapStopped', {
        text = '→', texthl = 'GruvboxOrangeBold', linehl = 'debugPC', numhl = ''
    })

    dap.adapters.lldb = {
        type = 'executable',
        command = (function()
            if utils.os() == "macos" then
                return '/opt/homebrew/opt/llvm/bin/lldb-dap'
            else
                return '/usr/bin/lldb-dap'
            end
        end)(),
        name = 'lldb'
    }

    local function get_template()
        return {
            name = '',
            type = 'lldb',
            request = 'launch',
            program = function()
                return dap_utils.pick_file({ executables = true })
            end,
            cwd = '${workspaceFolder}',
            console = '',
            postRunCommands = { 'process handle -p true -s false -n false SIGWINCH' },
            stopOnEntry = false,
            args = function()
                return dap_utils.splitstr(vim.fn.input('Args: ', '', 'file'))
            end,
        }
    end

    local integrated_config = get_template()
    integrated_config.name = "Integrated terminal"
    integrated_config.console = "integratedTerminal"

    local external_config = get_template()
    external_config.name = "External terminal"
    external_config.console = "externalTerminal"

    dap.configurations.c = {
        integrated_config,
        external_config
    }

    dap.configurations.cpp = dap.configurations.c

    dap.defaults.fallback.external_terminal = {
        command = (function()
            if utils.os() == "macos" then
                return "/opt/homebrew/bin/wezterm"
            else
                return "/usr/bin/wezterm"
            end
        end)(),
        args = {'-e'};
    }

    local term_buf
    local function terminal_win_cmd()
        term_buf = vim.api.nvim_create_buf(true, true)
        local term_win = vim.api.nvim_open_win(term_buf, false, {
            height = math.floor(vim.o.lines * 0.3), split = 'below', win = -1
        })

        return term_buf, term_win
    end

    vim.keymap.set('n', '<leader>bt', function()
        if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
            local win_list = vim.fn.win_findbuf(term_buf)

            if #win_list == 0 then
                vim.api.nvim_open_win(term_buf, false, {
                    height = math.floor(vim.o.lines * 0.3), split = 'below', win = -1
                })
            else
                for _, win in ipairs(win_list) do
                    vim.api.nvim_win_close(win, false)
                end
            end
        end
    end)

    dap.defaults.fallback.terminal_win_cmd = terminal_win_cmd

    vim.keymap.set('n', '<leader>bs', function() dap.continue() end)
    vim.keymap.set('n', '<leader>bl', function() dap.run_last() end)
    vim.keymap.set('n', '<leader>bb', function() dap.toggle_breakpoint() end)

    local widgets = require('dap.ui.widgets')

    local sidebar = nil
    local centered_float = nil
    local preview = nil

    dap.listeners.on_session["dap-binds-plug"] = function(_, new)
        if new then
            vim.keymap.set('n', '<leader>bc', function() dap.continue() end)
            vim.keymap.set('n', '<leader>bd', function() dap.step_over() end)
            vim.keymap.set('n', '<leader>bs', function() dap.step_into() end)
            vim.keymap.set('n', '<leader>bS', function() dap.step_out() end)
            vim.keymap.set('n', '<leader>gc', function() dap.run_to_cursor() end)
            vim.keymap.set({'n', 'v'}, '<leader>gK', function() widgets.hover() end)

            vim.keymap.set('n', '<leader>br', function()
                dap.repl.toggle(nil, "wincmd b | belowright vsp")
            end)

            vim.keymap.set('n', '<leader>fr', function()
                if not centered_float then
                    centered_float = widgets.centered_float(widgets.frames)
                end
                    centered_float.toggle()
            end)

            vim.keymap.set('n', '<leader>x', function()
                if not sidebar then
                    sidebar = widgets.sidebar(widgets.scopes)
                end
                sidebar.toggle()
            end)
        else
            if sidebar then
                sidebar.close()
            end
            if centered_float then
                centered_float.close()
            end
            if preview then
                preview.close()
            end

            dap.repl.close()
        end
    end
end

return M
