-----------------------------------------------------------------------
--- UI
----------------------------------------------------------------------
local _ = vim.api.nvim_create_namespace("CompletionHighlights")

vim.cmd("highlight SelectedMatch guifg=#83a598")

local window = { open = false, option = 0 }

local function close()
    if window.open == true then
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

local function open(completions)
    if #completions == 0 then
        return
    end

    -- CREATE BUFFER + SET COMPLETIONS
    window.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(window.buf, 0, 0, false, completions)

    -- CREATE FLOATING WINDOW
    local width = 20
    window.height = #completions <= 10 and #completions or 10
    local design = {
        relative = "cursor",
        col = -1,
        row = 1,
        width = width,
        height = window.height,
        style = "minimal",
        border = "rounded",
    }

    vim.api.nvim_open_win(window.buf, false, design)

    window.open = true
end

-- ERROR: (CLICKING FLOAT WINDOW + LEAVING INSERT MODE)
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
        close()

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

        open(get_completions())
    end
})

-- debug
vim.keymap.set("n", "<leader>rb", function()
    local buf = vim.api.nvim_get_current_buf()

    if vim.api.nvim_buf_get_option(buf, "buflisted") then
        files[buf] = refresh_buffer(buf)
    end
end)

vim.keymap.set("n", "<leader>rr", function()

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
