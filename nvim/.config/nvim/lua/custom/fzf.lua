local utils = require("custom.utils")

local fzf_default =
    "fzf --color=pointer:#E67E22,prompt:#E67E22 " ..
        "--prompt='> ' " ..
        "--layout=reverse " ..
        "--preview 'bat --style=changes --color=always {}' " ..
        "--preview-window=right:70%:wrap:noinfo " ..
        "--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down "

local float_width = vim.o.columns
local float_height = vim.o.lines - 2 -- dont cover status bar

local float_design = {
    style = "minimal",
    relative = "editor",
    width = float_width,
    height = float_height,
    row = 0,
    col = 0,
    border = "none",
}

local function get_temp()
    local temp_dir = vim.fn.stdpath("data") .. "/fzf_temp"
    if vim.fn.isdirectory(temp_dir) == 0 then
        vim.fn.mkdir(temp_dir, "p")
    end

    return temp_dir .. "/result-" .. vim.fn.getpid() .. ".txt"
end

local function live_grep()
    --- Create scratch buf, open in floating win ---
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Live Grep "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    --- Generate temp file for fzf selection ---
    local temp_file = get_temp()

    local fzf_extra = [[
    --no-hscroll \
    --ansi --phony --disabled --delimiter=':' \
    --bind "change:reload:rg -F --color=always --hidden --line-number --smart-case -- {q} || true" \
    --preview 'bat \
      --paging=never --color=always --style=numbers,header,changes,grid \
      --highlight-line {2} --line-range {2}: {1}' \
    ]]

    --- Execute fzf ---
    vim.fn.jobstart(fzf_default .. fzf_extra .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then

                        local selected = fd:read("*l")
                        fd:close()
                        vim.fn.delete(temp_file)

                        vim.cmd("close")

                        vim.cmd("e " .. selected:match("[^:]+"))
                        vim.cmd(selected:match(":(%d+)"))
                        vim.cmd("normal! zz")
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
    vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
end

local function edit_dotfiles()
    --- Create scratch buf, open in floating win ---
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Dotfiles "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    --- Generate temp file for fzf selection ---
    local temp_file = get_temp()

    local hostname = vim.fn.hostname()

    local dot_picker
    if vim.loop.os_uname().sysname == "Linux" then
        dot_picker = "rg --hidden --files /home/ammsiss/dotfiles"
    else -- macos ?
        dot_picker = "rg --hidden --files /Users/ammsiss/dotfiles"
    end

    --- Execute fzf ---
    vim.fn.jobstart(dot_picker .. "|" .. fzf_default .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then

                        local selected = fd:read("*l")
                        fd:close()
                        vim.fn.delete(temp_file)

                        vim.cmd("close")

                        vim.cmd("e " .. selected)
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
    vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
end

local function git_status()
    --- Create scratch buf, open in floating win ---
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Git Status "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    --- Generate temp file for fzf selection ---
    local temp_file = get_temp()

    --- Get git root if exists ---
    local result = vim.system(
        { "git", "rev-parse", "--show-toplevel" },
        { text = true }
    ):wait()

    if result.code ~= 0 then
        print(result.stderr)
        return
    end

    local git_root = result.stdout:sub(1, -2) -- trim newline

    local gs_picker =
        "git diff --name-only --diff-filter=ACMRT HEAD"

    local fzf_extra =
        "--preview='repo=" .. git_root ..
       [[; bat --style=changes --color=always "$repo"/{}' ]]

    --- Execute fzf ---
    vim.fn.jobstart(gs_picker .. "|" .. fzf_default .. fzf_extra .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then

                        local selected = fd:read("*l")
                        fd:close()
                        vim.fn.delete(temp_file)

                        vim.cmd("close")

                        vim.cmd("e " .. git_root .. "/" .. selected)
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
    vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
end

local function find_files()

    -- Create scratch buf, open in floating win
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Find Files "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    -- Generate temp file for fzf selection
    local temp_file = get_temp()

    local cd_picker = "rg --files --hidden"

    vim.fn.jobstart(cd_picker .. "|" .. fzf_default .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then

                        local selected = fd:read("*l")
                        fd:close()
                        vim.fn.delete(temp_file)

                        vim.cmd("close")

                        vim.cmd("e " .. selected)
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
    vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
end

local function find_files_split()

    -- Create scratch buf, open in floating win
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Find Files "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    -- Generate temp file for fzf selection
    local temp_file = get_temp()

    local cd_picker = "rg --files --hidden"

    vim.fn.jobstart(cd_picker .. "|" .. fzf_default .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then

                        local selected = fd:read("*l")
                        fd:close()
                        vim.fn.delete(temp_file)

                        vim.cmd("close")

                        vim.cmd("vsp")
                        utils.c_cmd("<C-w>L")

                        vim.cmd("e " .. selected)
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
    vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
end

-- local buffers = vim.api.nvim_list_bufs()
-- for _, buf in ipairs(buffers) do
--     if vim.api.nvim_buf_is_loaded(buf) then
--         print(vim.api.nvim_buf_get_name(buf))
--     end
-- end
--
-- local function find_files_buf()
--
--     -- Create scratch buf, open in floating win
--     local buf = vim.api.nvim_create_buf(false, true)
--     float_design.title = " Find Files "
--     float_design.title_pos = "center"
--     vim.api.nvim_open_win(buf, true, float_design)
--
--     -- Generate temp file for fzf selection
--     local temp_file = get_temp()
--
--     local cd_picker = "rg --files --hidden"
--
--     vim.fn.jobstart(cd_picker .. "|" .. fzf_default .. ">" .. temp_file, {
--             term = true,
--             on_exit = function(_, exit_code, _)
--                 if exit_code == 0 then
--                     local fd = io.open(temp_file, "r")
--                     if fd then
--
--                         local selected = fd:read("*l")
--                         fd:close()
--                         vim.fn.delete(temp_file)
--
--                         vim.cmd("close")
--
--                         vim.cmd("vsp")
--                         utils.c_cmd("<C-w>L")
--
--                         vim.cmd("e " .. selected)
--                     end
--                 else
--                     vim.cmd("close")
--                 end
--             end
--         }
--     )
--     vim.api.nvim_feedkeys("i", "n", false)
--     vim.keymap.set("t", "<ESC>", function() vim.cmd("close") end, { buffer = 0 })
-- end

vim.keymap.set("n", "<leader>fg", live_grep, {})
vim.keymap.set("n", "<leader>fd", find_files, {})
vim.keymap.set("n", "<leader>os", find_files_split, {})
-- vim.keymap.set("n", "<leader>os", find_files_buf, {})
vim.keymap.set("n", "<leader>gs", git_status, {})
vim.keymap.set("n", "<leader>en", edit_dotfiles, {})
