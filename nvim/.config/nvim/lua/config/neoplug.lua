-- Some sort of prompt when plugin needs update
-- Refactor plugin updating to not rely on 'plugins' state
-- Replace vim.fn.system with vim.system

local M = {}

local neo_path = vim.fn.stdpath("data") .. "/neoplug"
vim.fn.mkdir(neo_path .. "/pack/packages/opt", "p")
vim.opt.packpath:append(neo_path)
-- Add neoplug to packpath

local plugins = {}
local plugin_names = {}
local layers = {}

function M.setup(spec, opts)
    -- Load plugins in specified path
    local plug_path = vim.fn.stdpath("config") .. "/lua/" .. spec.path
    local scandir = vim.loop.fs_scandir(plug_path)

    if scandir then
        while true do
            local name = vim.loop.fs_scandir_next(scandir)
            if not name then break end

            local mod_name = spec.path .. "." .. name:gsub("%.lua$", "")
            table.insert(plugins, require(mod_name))
        end
    end

    if spec.extra then
        for _, plug in ipairs(spec.extra) do
            table.insert(plugins, plug)
        end
    end

    -- Extract plugin name
    for i = 1, #plugins, 1 do
        local plugin_name = ""
        local past_delim = false
        for y = 1, #plugins[i].name, 1 do
            if past_delim then
                plugin_name = plugin_name .. string.sub(plugins[i].name, y, y)
            elseif string.sub(plugins[i].name, y, y) == "/" then
                past_delim = true
            end
        end
        plugin_names[i] = plugin_name
        plugins[i].p_name = plugin_name
    end

    -- Install plugins if not already
    for i = 1, #plugins, 1 do
        local plugin_path = neo_path .. "/pack/packages/opt/" .. plugin_names[i]

        if vim.fn.empty(vim.fn.glob(plugin_path)) == 1 then
            vim.fn.system({
                "git", "clone",
                "https://github.com/" .. plugins[i].name,
                plugin_path
            })

            print(plugin_names[i] .. " Installed and loaded.")
        end
    end

    local function update_one(to_update)
        local plugin_path = neo_path .. "/pack/packages/opt/" .. to_update

        vim.fn.jobstart({ "git", "-C", plugin_path, "fetch" }, {
            on_exit = function()
                local result = {}
                vim.fn.jobstart({ "git", "-C", plugin_path, "status" }, {
                    on_stdout = function(_, data)
                        for _, line in ipairs(data) do
                            table.insert(result, line)
                        end
                    end,
                    on_exit = function()
                        local total_data = table.concat(result, "\n")
                        if not string.find(total_data, "Your branch is up to date") then
                            vim.fn.jobstart({ "git", "-C", plugin_path, "pull" }, {
                                on_exit = function()
                                    print(to_update .. " updated.")
                                    local index
                                    for i, plugin in ipairs(plugins) do
                                        if to_update == plugin.p_name then
                                            index = i
                                        end
                                    end
                                    if plugins[index].build then
                                        vim.cmd(plugins[index].build)
                                    end
                                end
                            })
                        else
                            print(to_update .. " already up to date")
                        end
                    end
                })
            end
        })
    end

    local function update_plugins()
        -- Async auto update plugins
        for i = 1, #plugin_names, 1 do

            local plugin_path = neo_path .. "/pack/packages/opt/" .. plugin_names[i]
            local plugin_name = plugin_names[i]

            vim.fn.jobstart({ "git", "-C", plugin_path, "fetch" }, {
                on_exit = function()
                    local result = {}
                    vim.fn.jobstart({ "git", "-C", plugin_path, "status" }, {
                        on_stdout = function(_, data)
                            for _, line in ipairs(data) do
                                table.insert(result, line)
                            end
                        end,
                        on_exit = function()
                            local total_data = table.concat(result, "\n")
                            if not string.find(total_data, "Your branch is up to date") then
                                vim.fn.jobstart({ "git", "-C", plugin_path, "pull" }, {
                                    on_exit = function()
                                        print(plugin_name .. " updated.")
                                        if plugins[i].build then
                                            vim.cmd(plugins[i].build)
                                            print("BUILD " .. plugins[i].build)
                                        end
                                    end
                                })
                            end
                        end
                    })
                end
            })
        end
    end
    if opts.auto_update or opts.auto_update == nil then
        update_plugins()
    end

    -- Dependency Sort
    layers = { plugins }

    local function move_down(name, layer_number)
        for i = layer_number, #layers, 1 do
            for _, plugin in ipairs(layers[i]) do
                if name == plugin.name then
                    return i + 1
                end
            end
        end

        return false
    end

    ::skip::
    for l = 1, #layers, 1 do
        for p, plugin in ipairs(layers[l]) do
            if plugin.expects then
                for _, dependent in ipairs(plugin.expects) do
                    local layer = move_down(dependent, l)
                    if layer then
                        if layers[layer] then
                            table.insert(layers[layer], plugin)
                            table.remove(layers[l], p)
                            goto skip
                        else
                            table.insert(layers, { plugin })
                            table.remove(layers[l], p)
                            goto skip
                        end
                    end
                end
            end
        end
    end

    local priority_plug = {}
    for _, layer in ipairs(layers) do
        for _, plugin in ipairs(layer) do
            if plugin.priority then
                table.insert(priority_plug, plugin)
            end
        end
    end

    table.sort(priority_plug, function(a, b) return a.priority > b.priority end)

    -- load priority plugins first
    for _, plugin in ipairs(priority_plug) do
        if plugin.enabled or plugin.enabled == nil then
            vim.cmd("packadd " .. plugin.p_name)
            if plugin.config then
                plugin.config()
            end
        end
    end

    -- Load Plugins in order
    for _, layer in ipairs(layers) do
        for _, plugin in ipairs(layer) do
            if plugin.enabled or plugin.enabled == nil then
                if not plugin.priority then
                    vim.cmd("packadd " .. plugin.p_name)
                    if plugin.config then
                        plugin.config()
                    end
                end
            end
        end
    end

    -- Neoplug commands
    vim.api.nvim_create_user_command("Neoplug", function()
        local buf = vim.api.nvim_create_buf(false, true) -- create new (scratch) buffer

        --vim.cmd("highlight NeoplugHeader gui=bold guifg=#6FB3B8")
        vim.cmd("highlight NeoplugPluginName guifg=#E67E22")
        vim.cmd("highlight NeoplugDependency guifg=#b8bb26")
        vim.cmd("highlight NeoplugBanner gui=bold guifg=#b8bb26")
        vim.cmd("highlight NeoplugLayer guifg=#bdae93")

        local output = {}
        table.insert(output, "   /\\  /\\___  ___  _ __ | |_   _  __ _")
        table.insert(output, "  /  \\/ / _ \\/ _ \\| '_ \\| | | | |/ _` |")
        table.insert(output, " / /\\  /  __/ (_) | |_) | | |_| | (_| |")
        table.insert(output, " \\_\\ \\/ \\___|\\___/| .__/|_|\\__,_|\\__, |")
        table.insert(output, "                  |_|            |___/")

        table.insert(output, "")
        table.insert(output, " ==== Installed Plugins" .. " (total " .. #plugin_names .. ") ====")
        table.insert(output, "")
        table.insert(output, " Layer 0" .. " (priority load)")
        table.insert(output, "")

        local plugin_lines = {}
        for _, plugin in ipairs(priority_plug) do
            if plugin.enabled or plugin.enabled == nil then
                local str = " ● " .. plugin.p_name .. " (priority " .. plugin.priority .. ")"
                table.insert(output, str)
                plugin_lines[#output] = plugin.p_name
                if plugin.expects then
                    for _, dependency in ipairs(plugin.expects) do
                        table.insert(output, "     " .. dependency)
                    end
                end
            end
        end
        table.insert(output, "")

        local none_disable = true
        for i, layer in ipairs(layers) do
            if i == 1 then
                table.insert(output, " Layer " .. i .. " (No dependencies)")
                table.insert(output, "")
            else
                table.insert(output, " Layer " .. i)
                table.insert(output, "")
            end
            for _, plugin in ipairs(layer) do
                if plugin.enabled or plugin.enabled == nil then
                    if not plugin.priority then
                        local str = " ● " .. plugin.p_name
                        table.insert(output, str)
                        plugin_lines[#output] = plugin.p_name
                        if plugin.expects then
                            for _, dependency in ipairs(plugin.expects) do
                                table.insert(output, "     " .. dependency)
                            end
                        end
                    end
                end
                if plugin.enabled == false then
                    none_disable = false
                end
            end
            table.insert(output, "")
        end

        if not none_disable then
            table.insert(output, " Disabled")
            table.insert(output, "")
            for _, layer in ipairs(layers) do
                for _, plugin in ipairs(layer) do
                    if plugin.enabled == false then
                        local str = " ○ " .. plugin.p_name
                        table.insert(output, str)
                        plugin_lines[#output] = plugin.p_name
                        if plugin.expects then
                            for _, dependency in ipairs(plugin.expects) do
                                table.insert(output, "     " .. dependency)
                            end
                        end
                    end
                end
                table.insert(output, "")
            end
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

        for i, line in ipairs(output) do
            if line:find("Installed Plugins") then
                vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugHeader", i - 1, 0, -1)
            elseif line:match("^%s● ") then
                local start_col, end_col = line:find("●")
                if start_col then
                    vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugPluginName", i - 1, start_col - 1, end_col)
                end
            elseif line:match("^%s○ ") then
                local start_col, end_col = line:find("○")
                if start_col then
                    vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugPluginName", i - 1, start_col - 1, end_col)
                end
            elseif line:match("^%s+") then
                vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugLayer", i - 1, 0, -1)
                local start_col, end_col = line:find("")
                if start_col then
                    vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugDependency", i - 1, start_col - 1, end_col)
                end
            elseif line:match("| |") or line:match("|_|") then
                vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugBanner", i - 1, 0, -1)
            elseif line:match("Layer") then
                vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugLayer", i - 1, 0, -1)
            elseif line:match("Disabled") then
                vim.api.nvim_buf_add_highlight(buf, -1, "NeoplugLayer", i - 1, 0, -1)
            end
        end

        local width = 40
        local view_port = math.floor(vim.o.lines * 0.7)
        local height = view_port > #output and #output or view_port
        if opts then
            if opts.height then
                height = math.floor(vim.o.lines * opts.height)
            end
        end
        local design = {
            style = "minimal",
            relative = "editor",
            width = width,
            height = height,
            row = (vim.o.lines - height) / 2,
            col = (vim.o.columns - width) / 2,
            border = "single",
        }
        if opts then
            if opts.ui then
                design = vim.tbl_extend("force", design, opts.ui)
            end
        end

        -- non modifiable
        vim.api.nvim_buf_set_option(buf, "modifiable", false)

        -- open the floating window
        vim.api.nvim_open_win(buf, true, design)

        vim.api.nvim_buf_set_keymap(buf, 'n', 'u', '', {
            noremap = true,
            silent = true,
            callback = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local line_num = cursor[1]

                if plugin_lines[line_num] then
                    update_one(plugin_lines[line_num])
                end
            end
        })


        vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
    end, {})
end

return M
