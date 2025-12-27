---@class plugin_spec
---@field slug string -- Repo slug for plugin
---@field enabled? boolean -- True by defualt
---@field expects? table<integer, plugin_spec> -- Dependency plugins
---@field config? function -- Set up function for plugin
---@field build? string -- Build command
---@field priority? integer -- Load priority: 1 - 1000

---@class neoplug_opts
---@field auto_update? boolean -- True by default
---@field height? integer -- Floating window height

---@class neoplug_spec
---@field path string -- Path to plugin directory in runtime path
---@field extra? table<integer, plugin_spec> Inline plugin additions

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

    for _, plugin in ipairs(plugins) do
        local name = vim.fs.basename(plugin.slug)
        local plugin_path = plug_dir .. name

        if vim.fn.isdirectory(plugin_path) ~= 1 then
            local sys_opts = { cwd = plug_dir }
            local clone_cmd = { "git", "clone", "https://github.com/" ..
                plugin.slug }

            vim.system(clone_cmd, sys_opts, function()
                vim.schedule(function()
                    vim.notify(name .. " Installed",
                        vim.log.levels.INFO)
                end)
            end)
        end
    end

    ---@param plugin plugin_spec
    local function update_plugin(plugin)

        local name = vim.fs.basename(plugin.slug)
        local sys_opts = { cwd = plug_dir .. name }
        local fetch_cmd = { "git", "fetch" }
        local behind_cmd = { "git", "rev-list", "--count", "HEAD..@{u}" }

        vim.system(fetch_cmd, sys_opts, function()
            vim.system(behind_cmd, sys_opts, function(obj)
                local behind = tonumber(obj.stdout)
                if (behind and behind > 0) then
                    vim.system({ "git", "pull" }, sys_opts, function()
                        if (plugin.build) then
                            vim.schedule(function()
                                vim.cmd(plugin.build)
                            end)
                        end
                    end)
                end
            end)
        end)
    end

    local function update_plugins()
        for _, plugin in ipairs(plugins) do
            update_plugin(plugin)
        end
    end

    if opts.auto_update ~= nil then
        update_plugins()
    end

    vim.cmd("helptags ALL");

    table.sort(plugins, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    for _, plugin in ipairs(plugins) do
        if plugin.enabled ~= false then
            local name = vim.fs.basename(plugin.slug)
            vim.cmd("packadd " .. name)
            if plugin.config then
                plugin.config()
            end
        end
    end

    -- vim.api.nvim_create_user_command("Neoplug", function()
    --
    --     local buf = vim.api.nvim_create_buf(false, true) -- create new (scratch) buffer
    --
    --
    -- end, { desc = "Neoplug status display in a floating window" })

--    -- Neoplug commands
--     vim.api.nvim_create_user_command("Neoplug", function()
--         local buf = vim.api.nvim_create_buf(false, true) -- create new (scratch) buffer
--
--         --vim.cmd("highlight NeoplugHeader gui=bold guifg=#6FB3B8")
--         vim.cmd("highlight NeoplugPluginName guifg=#E67E22")
--         vim.cmd("highlight NeoplugDependency guifg=#b8bb26")
--         vim.cmd("highlight NeoplugBanner gui=bold guifg=#b8bb26")
--         vim.cmd("highlight NeoplugLayer guifg=#bdae93")
--
--         local output = {}
--         table.insert(output, "   /\\  /\\___  ___  _ __ | |_   _  __ _")
--         table.insert(output, "  /  \\/ / _ \\/ _ \\| '_ \\| | | | |/ _` |")
--         table.insert(output, " / /\\  /  __/ (_) | |_) | | |_| | (_| |")
--         table.insert(output, " \\_\\ \\/ \\___|\\___/| .__/|_|\\__,_|\\__, |")
--         table.insert(output, "                  |_|            |___/")
--
--         table.insert(output, "")
--         table.insert(output, " ==== Installed Plugins" .. " (total " .. #plugin_names .. ") ====")
--         table.insert(output, "")
--         table.insert(output, " Layer 0" .. " (priority load)")
--         table.insert(output, "")
--
--         local plugin_lines = {}
--         for _, plugin in ipairs(priority_plug) do
--             if plugin.enabled or plugin.enabled == nil then
--                 local str = " ● " .. plugin.p_name .. " (priority " .. plugin.priority .. ")"
--                 table.insert(output, str)
--                 plugin_lines[#output] = plugin.p_name
--                 if plugin.expects then
--                     for _, dependency in ipairs(plugin.expects) do
--                         table.insert(output, "     " .. vim.fs.basename(dependency.p_name))
--                     end
--                 end
--             end
--         end
--         table.insert(output, "")
--
--         local none_disable = true
--         for i, layer in ipairs(layers) do
--             if i == 1 then
--                 table.insert(output, " Layer " .. i .. " (No dependencies)")
--                 table.insert(output, "")
--             else
--                 table.insert(output, " Layer " .. i)
--                 table.insert(output, "")
--             end
--             for _, plugin in ipairs(layer) do
--                 if plugin.enabled or plugin.enabled == nil then
--                     if not plugin.priority then
--                         local str = " ● " .. plugin.p_name
--                         table.insert(output, str)
--                         plugin_lines[#output] = plugin.p_name
--                         if plugin.expects then
--                             for _, dependency in ipairs(plugin.expects) do
--                                 table.insert(output, "     " .. vim.fs.basename(dependency.name))
--                             end
--                         end
--                     end
--                 end
--                 if plugin.enabled == false then
--                     none_disable = false
--                 end
--             end
--             table.insert(output, "")
--         end
--
--         if not none_disable then
--             table.insert(output, " Disabled")
--             table.insert(output, "")
--             for _, layer in ipairs(layers) do
--                 for _, plugin in ipairs(layer) do
--                     if plugin.enabled == false then
--                         local str = " ○ " .. plugin.p_name
--                         table.insert(output, str)
--                         plugin_lines[#output] = plugin.p_name
--                         if plugin.expects then
--                             for _, dependency in ipairs(plugin.expects) do
--                                 table.insert(output, "     " .. vim.fs.basename(dependency.name))
--                             end
--                         end
--                     end
--                 end
--             end
--             table.insert(output, "")
--         end
--
--         vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
--
--         local ns = vim.api.nvim_create_namespace("neoplug")
--
--         for i, line in ipairs(output) do
--             if line:find("Installed Plugins") then
--                 vim.hl.range(buf, ns, "NeoplugHeader", { i - 1, 0 }, { i - 1, -1 })
--             elseif line:match("^%s● ") then
--                 local start_col, end_col = line:find("●")
--                 if start_col then
--                     vim.hl.range(buf, ns, "NeoplugPluginName", { i - 1, start_col - 1 }, { i - 1, end_col })
--                 end
--             elseif line:match("^%s○ ") then
--                 local start_col, end_col = line:find("○")
--                 if start_col then
--                     vim.hl.range(buf, ns, "NeoplugPluginName", { i - 1, start_col - 1 }, { i - 1, end_col })
--                 end
--             elseif line:match("^%s+") then
--                 vim.hl.range(buf, ns, "NeoplugLayer", { i - 1, 0 }, { i - 1, -1 })
--                 local start_col, end_col = line:find("")
--                 if start_col then
--                     vim.hl.range(buf, ns, "NeoplugDependency", { i - 1, start_col - 1 }, { i - 1, end_col })
--                 end
--             elseif line:match("| |") or line:match("|_|") then
--                 vim.hl.range(buf, ns, "NeoplugBanner", { i - 1, 0 }, { i - 1, -1 })
--             elseif line:match("Layer") then
--                 vim.hl.range(buf, ns, "NeoplugLayer", { i - 1, 0 }, { i - 1, -1 })
--             elseif line:match("Disabled") then
--                 vim.hl.range(buf, ns, "NeoplugLayer", { i - 1, 0 }, { i - 1, -1 })
--             end
--         end
--
--         local width = 40
--         local view_port = math.floor(vim.o.lines * 0.7)
--         local height = view_port > #output and #output or view_port
--         if opts then
--             if opts.height then
--                 height = math.floor(vim.o.lines * opts.height)
--             end
--         end
--         local design = {
--             style = "minimal",
--             relative = "editor",
--             width = width,
--             height = height,
--             row = (vim.o.lines - height) / 2,
--             col = (vim.o.columns - width) / 2,
--             border = "single",
--         }
--
--         -- non modifiable
--         vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
--
--         -- open the floating window
--         vim.api.nvim_open_win(buf, true, design)
--
--         vim.api.nvim_buf_set_keymap(buf, 'n', 'u', '', {
--             noremap = true,
--             silent = true,
--             callback = function()
--                 local cursor = vim.api.nvim_win_get_cursor(0)
--                 local line_num = cursor[1]
--
--                 if plugin_lines[line_num] then
--                     update_one(plugin_lines[line_num])
--                 end
--             end
--         })
--
--
--         vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
--     end, {})

end
return M
