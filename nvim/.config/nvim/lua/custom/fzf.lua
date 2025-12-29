local fzf_default =
    "fzf --color=pointer:#E67E22,prompt:#E67E22 " ..
        "--prompt='> ' " ..
        "--layout=reverse " ..
        "--preview 'bat --style=changes --color=always {}' " ..
        "--preview-window=right:70%:wrap:noinfo " ..
        "--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down "

local float_design = {
    style = "minimal",
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines - 2, -- Don't cover status bar
    row = 0,
    col = 0,
    border = "none",
}

local function start_fzf(picker, fzf_extra, edit_func)
    fzf_extra = fzf_extra or ""
    edit_func = edit_func or function(selection)
        vim.cmd("e " .. selection)
    end

    -- Generate temp file for fzf selection
    local temp_file = vim.fn.tempname()

    vim.fn.jobstart(
        picker .. "|" .. fzf_default .. fzf_extra .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then
                        local selection = fd:read("*l")
                        fd:close()

                        vim.cmd("close")

                        edit_func(selection)
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

local function open_term_win()
    -- Create scratch buf, open in floating win
    local buf = vim.api.nvim_create_buf(false, true)

    float_design.width = vim.o.columns
    float_design.height = vim.o.lines - 2

    vim.api.nvim_open_win(buf, true, float_design)
end

local function find_files()
    open_term_win()
    start_fzf("rg --files --hidden")
end

local function edit_nexus()
    open_term_win()
    start_fzf("rg --hidden --files ~/Nexus")
end

local function edit_dotfiles()
    open_term_win()
    start_fzf("rg --hidden --files ~/dotfiles")
end

local function live_grep()
    local fzf_extra = [[
    --no-hscroll \
    --ansi --phony --disabled --delimiter=':' \
    --bind "change:reload:rg -F --color=always --hidden --line-number --smart-case -- {q} || true" \
    --preview 'bat \
      --paging=never --color=always --style=numbers,header,changes,grid \
      --highlight-line {2} --line-range {2}: {1}' \
    ]]

    open_term_win()
    start_fzf("ls", fzf_extra, function(selection)
        vim.cmd("e " .. selection:match("[^:]+"))
        vim.cmd(selection:match(":(%d+)"))
        vim.cmd("normal! zz")
    end)
end

local function git_status()
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

    open_term_win()
    start_fzf(gs_picker, fzf_extra, function(selected)
        vim.cmd("e " .. git_root .. "/" .. selected)
    end)
end

-- TO ADD

-- Command for buffers

vim.keymap.set("n", "<leader>fd", find_files, {})
vim.keymap.set("n", "<leader>en", edit_dotfiles, {})
vim.keymap.set("n", "<leader>eo", edit_nexus, {})
vim.keymap.set("n", "<leader>fg", live_grep, {})
vim.keymap.set("n", "<leader>gs", git_status, {})
