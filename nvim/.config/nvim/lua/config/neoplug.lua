---@class plugin_spec
---@field slug string -- Repo slug for plugin
---@field enabled? boolean -- True by defualt
---@field expects? table<integer, plugin_spec> -- Dependency plugins
---@field config? function -- Set up function for plugin
---@field build? string -- Build command
---@field priority? integer -- Load priority: 1 - 1000

---@class neoplug_opts
---@field height? integer -- Floating window height

---@class neoplug_spec
---@field path string -- Path to plugin directory in runtime path
---@field extra? table<integer, plugin_spec> Inline plugin additions

-- Test with no internet. Shitll blow up
--
-- Add git real time progress bar (parse git clone/git pull output)
-- Do a naive paint of stdout from the git commands to see how it looks

local M = {}

---@type string
local neo_path = vim.fn.stdpath("data") .. "/neoplug/"
vim.opt.packpath:append(neo_path)

---@type string
local plug_dir = neo_path .. "pack/packages/opt/"
vim.fn.mkdir(plug_dir, "p")

---@type plugin_spec[]
local plugins = {}

---@param spec neoplug_spec
---@param opts? neoplug_opts
function M.setup(spec, opts)

    opts = opts or {}

    ---@type string
    local plug_path = vim.fn.stdpath("config") .. "/lua/" .. spec.path

    local scandir = vim.loop.fs_scandir(plug_path)

    if scandir then
        while true do
            local fname = vim.loop.fs_scandir_next(scandir)
            if not fname then break end

            local module = spec.path .. "." .. fname:gsub("%.lua$", "")
            table.insert(plugins, require(module))
        end
    end

    if spec.extra then
        for _, plugin in ipairs(spec.extra) do
            table.insert(plugins, plugin)
        end
    end

    for _, plugin in ipairs(plugins) do
        if plugin.expects then
            for _, dependency in ipairs(plugin.expects) do
                table.insert(plugins, dependency)
            end
        end
    end

    table.sort(plugins, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    -- Clone -- 
    for _, plugin in ipairs(plugins) do
        local name = vim.fs.basename(plugin.slug)
        local plugin_path = plug_dir .. name

        if vim.fn.isdirectory(plugin_path) == 0 then
            local sys_opts = { cwd = plug_dir }
            local clone_cmd = { "git", "clone", "https://github.com/" ..
                plugin.slug }

            local obj = vim.system(clone_cmd, sys_opts):wait()

            if obj.code == 0 then
                vim.notify("Installed " .. name, vim.log.levels.INFO)

                local doc_path = plugin_path .. "/doc"
                if vim.fn.isdirectory(doc_path) ~= 0 then
                    vim.cmd("helptags " .. doc_path);
                end
            else
                vim.notify("Error installing " .. name .. "\n" .. obj.stderr,
                    vim.log.levels.ERROR)
            end
        end
    end

    for _, plugin in ipairs(plugins) do
        if plugin.enabled ~= false then
            local name = vim.fs.basename(plugin.slug)
            vim.cmd("packadd " .. name)
            if plugin.config then
                plugin.config()
            end
        end
    end

    local function log_error(obj)
        vim.schedule(function()
            vim.notify("Neoplug: " .. obj.stderr,
                vim.log.levels.ERROR)
        end)
    end

    ---@param plugin plugin_spec
    local function update_plugin(plugin)
        local name = vim.fs.basename(plugin.slug)
        local sys_opts = { cwd = plug_dir .. name }
        local fetch_cmd = { "git", "fetch" }
        local behind_cmd = { "git", "rev-list", "--count", "HEAD..@{u}" }
        local pull_cmd = { "git", "pull" }

        vim.system(fetch_cmd, sys_opts, function(fetch_obj)
            if fetch_obj.code ~= 0 then
                log_error(fetch_obj)
                return
            end

            vim.system(behind_cmd, sys_opts, function(behind_obj)
                if behind_obj.code ~= 0 then
                    log_error(behind_obj)
                    return
                end

                local behind = tonumber(behind_obj.stdout)

                if (behind and behind > 0) then
                    vim.system(pull_cmd, sys_opts, function(pull_obj)
                        if pull_obj.code ~= 0 then
                            log_error(pull_obj)
                            return
                        end

                        vim.schedule(function()
                            vim.notify("Updated " .. plugin.slug)
                            if (plugin.build) then
                                vim.cmd(plugin.build)
                            end
                        end)
                    end)
                end
            end)
        end)
    end

    vim.api.nvim_create_user_command("NeoplugUpdate", function()
        for _, plugin in ipairs(plugins) do
            update_plugin(plugin)
        end
    end, { desc = "Update all plugins" })

    vim.api.nvim_create_user_command("Neoplug", function()
        local gruvbox = require("custom.color").gruvbox
        local groups = { NeoplugGreen = { fg = gruvbox.bright_green }, }
        for name, val in pairs(groups) do
            vim.api.nvim_set_hl(0, name, val)
        end

        local buf = vim.api.nvim_create_buf(false, true)

        local output = {}

        table.insert(output, "")
        table.insert(output, "# Total: " .. #plugins)
        table.insert(output, "")

        for _, plugin in ipairs(plugins) do
            local name = vim.fs.basename(plugin.slug)

            if plugin.enabled ~= false then
                table.insert(output, " - " .. name)
            end
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
        vim.treesitter.start(buf, "markdown")
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        local width = math.floor(vim.o.columns * 0.7)
        local height = math.floor(vim.o.lines * 0.7)

        local design = {
            style = "minimal",
            relative = "editor",
            height = height,
            width = width,
            row = (vim.o.lines - height) / 2,
            col = (vim.o.columns - width) / 2,
            border = "rounded",
        }

        vim.api.nvim_open_win(buf, true, design)
    end, { desc = "Neoplug status display in a floating window" })
end

return M
