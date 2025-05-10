----------------------------------------------------------------------
--- UI - wilber wilson wigger watson wilber
----------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace("CompletionHighlights")
vim.cmd("highlight Selection guifg=#00FFFF")

local window = { open = false, option = -1, original = "" }

local function get_win_id()
    if vim.api.nvim_buf_is_valid(window.buf) then
        local win_list = vim.api.nvim_list_wins()
        for _, win in ipairs(win_list) do
            if vim.api.nvim_win_get_buf(win) == window.buf then
                return win
            end
        end
    end
    return nil
end

local function close()
    if window.open == true then

        window.option = -1

        local current_win = vim.api.nvim_get_current_win()

        if vim.api.nvim_buf_is_valid(window.buf) then
            local win_list = vim.api.nvim_list_wins()
            for _, win in ipairs(win_list) do
                if vim.api.nvim_win_get_buf(win) == window.buf then
                    vim.api.nvim_set_current_win(win)
                    vim.cmd("bd")
                    vim.api.nvim_set_current_win(current_win)
                    window.open = false
                end
            end
        end
    end
end

local function set_hl()

    vim.api.nvim_buf_clear_namespace(
        window.buf, ns, 0, -1
    )

    vim.hl.range(
        window.buf, ns, "Selection",
        { window.option, 0 },
        { window.option, -1 }
    )
end

local function set_original_word()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()

    local char = line:sub(col, col)
    local word = ""

    local i = 1
    while char ~= " " and char ~= "" do

        word = word .. char

        char = line:sub(col - i, col - i)
        i = i + 1
    end
    window.original = word:reverse()
end

local function open(completions)
    close()

    if #completions == 0 then
        return
    end

    set_original_word()

    vim.keymap.set("i", "<C-n>", function()
        if window.open == true then
            if window.option < #completions - 1 then
                window.option = window.option + 1
                set_hl()
            end

            if window.option % 10 == 0 and window.option ~= 0 then
                local win_id = get_win_id()
                if win_id then
                    vim.api.nvim_win_call(win_id, function()
                        for _ = 1, 10, 1 do
                            vim.cmd('execute "normal! \\<C-e>"')
                        end
                    end)
                end
            end
        end
    end)

    vim.keymap.set("i", "<C-p>", function()
        if window.option % 10 == 0 and window.option ~= 0 then
            local win_id = get_win_id()
            if win_id then
                vim.api.nvim_win_call(win_id, function()
                    for _ = 1, 10, 1 do
                        vim.cmd('execute "normal! \\<C-y>"')
                    end
                end)
            end
        end

        if window.open == true then
            if window.option > -1 then
                window.option = window.option - 1
                set_hl()
            end
        end
    end)

    vim.keymap.set("i", "<C-y>", function()
        if window.option == -1 then
            close()
            return
        end

        for _ = 1, #window.original, 1 do
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<BS>", true, false, true), "m", false)
        end

        vim.api.nvim_feedkeys(completions[window.option + 1], "m", false)
    end)

    -- CREATE BUFFER
    window.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(window.buf, 0, 0, false, completions)
    if window.option ~= -1 then
        set_hl()
    end

    -- CREATE FLOATING WINDOW

    local longest = 0
    for _, comp in ipairs(completions) do
        if #comp > longest then
            longest = #comp
        end
    end

    local width = longest
    window.height = #completions <= 10 and #completions or 10

    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local top_line = vim.fn.line("w0")
    local bottom = vim.api.nvim_win_get_height(0)

    local row = 1

    if (bottom + top_line) - cursor_line <= 12 then
        row = -(window.height + 2)
    end

    local design = {
        relative = "cursor",
        col = -1,
        row = row,
        width = width,
        height = window.height,
        style = "minimal",
        border = "rounded",
        focusable = false,
    }

    vim.api.nvim_open_win(window.buf, false, design)

    window.open = true
end

vim.api.nvim_create_autocmd("InsertLeave", {
    callback = close
})

-----------------------------------------------------------------------
--- SOURCES - BUFFER
-----------------------------------------------------------------------
local files = {}
local pattern1 = [[\v[a-zA-Z0-9_]+]]
local pattern2 = [[\v-?\d+(\.\d+)?]]
local pattern3 = [["([^"]+)"]]

local function check_match(word)
    local out = vim.fn.matchstr(word, pattern3)

    if out == "" then
        out = vim.fn.matchstr(word, pattern2)
        if out == "" then
            out = vim.fn.matchstr(word, pattern1)
        end
    end

    return out
end

local function get_completions()
    local cursor_line = vim.api.nvim_get_current_line()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local buf = vim.api.nvim_get_current_buf()

    -- CREATE PREFIX
    local prefix = ""
    local prev_char = cursor_line:sub(col, col)

    local i = 1
    while prev_char ~= " " and prev_char ~= "" do
        prefix = prev_char .. prefix
        prev_char = cursor_line:sub(col - i, col - i)
        i = i + 1
    end

    if prefix == "" then
        return {}
    end
    -- MATCH PREFIX AGAINST BUFFER WORDS
    local completions = {}
    local seen_words = {}

    for _, line in ipairs(files[buf]) do
        for _, word in ipairs(line) do
            if word:sub(1, #prefix):upper() == prefix:upper() and word:upper() ~= prefix:upper() then

                local seen = false

                for _, seen_word in ipairs(seen_words) do
                    if seen_word == word then
                        seen = true
                    end
                end

                if not seen then
                    table.insert(completions, word)
                    table.insert(seen_words, word)
                end
            end
        end
    end

    return completions
end

local function refresh_buffer(buf)
    local out = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)

    for _, line in ipairs(lines) do

        local words_in_line = vim.split(line, " ", { trimempty = true })

        local tokenized_line = {}
        for _, word in ipairs(words_in_line) do
            local match = check_match(word)
            if match ~= "" then
                table.insert(tokenized_line, match)
            end
        end

        if #tokenized_line == 0 then
            table.insert(out, { "" })
        else
            table.insert(out, tokenized_line)
        end
    end

    return out
end

-----------------------------------------------------------------------
--- SOURCES - LSP
-----------------------------------------------------------------------

local function get_completions_lsp(callback)
    vim.lsp.buf_request(0, 'textDocument/completion', vim.lsp.util.make_position_params(0, 'utf-8'), function(err, result, _, _)
        if err or not result then return end

        local items = result.items or result

        local completions = {}
        for _, item in ipairs(items) do
            table.insert(completions, item.label)
        end

        callback(completions)
    end)
end

-----------------------------------------------------------------------
--- AUTO COMMANDS AND BINDS
-----------------------------------------------------------------------

vim.api.nvim_create_autocmd("BufWinEnter", {
    once = true,
    callback = function(opts)
        if vim.api.nvim_buf_get_option(opts.buf, "buflisted") then
            files[opts.buf] = refresh_buffer(opts.buf)
        end
    end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
    callback = function(opts)
        if vim.api.nvim_buf_get_option(opts.buf, "buflisted") then
            files[opts.buf] = refresh_buffer(opts.buf)
        end
    end
})

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(opts)
        if vim.api.nvim_buf_get_option(opts.buf, "buflisted") then
            files[opts.buf] = refresh_buffer(opts.buf)
        end
    end
})

vim.api.nvim_create_autocmd("TextChanged", {
    callback = function(opts)
        if vim.api.nvim_buf_get_option(opts.buf, "buflisted") and opts.buf ~= nil then
            files[opts.buf] = refresh_buffer(opts.buf)
        end
    end
})

vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_get_option(buf, "buflisted") then
            return
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line = vim.api.nvim_get_current_line()

        -- MATCH "" FOR START OF LINES
        if line:sub(col, col) == "" then
            local above_line

            if row == 1 then
                return
            end

            above_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]

            local words_in_line = vim.split(above_line, " ", { trimempty = true })
            local tokenized_line = {}

            for _, word in ipairs(words_in_line) do
                local match = check_match(word)
                if match ~= "" then
                    table.insert(tokenized_line, match)
                end
            end

            if #tokenized_line == 0 then
                files[buf][row - 1] = { "" }
            else
                files[buf][row - 1] = tokenized_line
            end
        elseif line:sub(col, col) == " " then
            local words_in_line = vim.split(vim.api.nvim_get_current_line(), " ", { trimempty = true })
            local tokenized_line = {}

            for _, word in ipairs(words_in_line) do
                local match = check_match(word)
                if match ~= "" then
                    table.insert(tokenized_line, match)
                end
            end

            if #tokenized_line == 0 then
                files[buf][row] = { "" }
            else
                files[buf][row] = tokenized_line
            end
        end

        close()

        -- LSP BUGGY AS ALL HELL
        local with_lsp = false

        if with_lsp then
            get_completions_lsp(function(results)
                local completions = {}
                local buf_comp = get_completions()
                for _, comp in ipairs(results) do
                    table.insert(completions, comp)
                end
                for _, comp in ipairs(buf_comp) do
                    table.insert(completions, comp)
                end
                open(completions)
            end)
        else
            open(get_completions())
        end
    end
})

-- debug
vim.keymap.set("n", "rb", function()
    local buf = vim.api.nvim_get_current_buf()

    if vim.api.nvim_buf_get_option(buf, "buflisted") then
        files[buf] = refresh_buffer(buf)
    end
end)

vim.keymap.set("n", "rr", function()

    local message = {}
    for _, line in ipairs(files[vim.api.nvim_get_current_buf()]) do

        local message_line = ""
        for _, word in ipairs(line) do
            message_line = message_line .. word .. " "
        end

        message_line = message_line .. "\n"

        table.insert(message, { message_line })
    end

    vim.api.nvim_echo(message, true, {})
end)
