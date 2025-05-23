local fzf_default =
    "fzf --color=pointer:#E67E22,prompt:#E67E22 " ..
        "--prompt='> ' " ..
        "--layout=reverse " ..
        "--preview 'bat --style=changes --color=always {}' " ..
        "--preview-window=right:70%:wrap:noinfo " ..
        "--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down "

local float_width = vim.o.columns
local float_height = vim.o.lines - 4 -- dont cover status bar

local float_design = {
    style = "minimal",
    relative = "editor",
    width = float_width,
    height = float_height,
    row = 0,
    col = 0,
    border = "rounded",
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

    local grep_picker = "rg --files"

    local fzf_extra = [[
    --ansi --phony --disabled --delimiter=':' \
    --bind "change:reload:rg --color=always --line-number --smart-case -- {q} || true" \
    --preview 'bat \
      --paging=never --color=always --style=changes \
      --highlight-line {2} --line-range {2}: {1}' \
    ]]

    --- Execute fzf ---
    vim.fn.jobstart(grep_picker .. "|" .. fzf_default .. fzf_extra .. ">" .. temp_file, {
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

                        -- vim.cmd("e " .. selected)
                    end
                else
                    vim.cmd("close")
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
end

local function edit_dotfiles()
    --- Create scratch buf, open in floating win ---
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Dotfiles "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    --- Generate temp file for fzf selection ---
    local temp_file = get_temp()

    local dot_picker =
        "rg --hidden --files /Users/ammsiss/dotfiles"

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
end

local function find_files()

    -- Create scratch buf, open in floating win
    local buf = vim.api.nvim_create_buf(false, true)
    float_design.title = " Find Files "
    float_design.title_pos = "center"
    vim.api.nvim_open_win(buf, true, float_design)

    -- Generate temp file for fzf selection
    local temp_file = get_temp()

    local cd_picker = "rg --files"

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
end

vim.keymap.set("n", "<leader>fg", live_grep, {})
vim.keymap.set("n", "<leader>fd", find_files, {})
vim.keymap.set("n", "<leader>gs", git_status, {})
vim.keymap.set("n", "<leader>en", edit_dotfiles, {})
