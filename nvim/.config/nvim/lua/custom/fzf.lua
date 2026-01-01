-- Create api that converst fzf options into a programmaable data.

local fzf_default = [[
    fzf \
        --color 'pointer:#E67E22,prompt:#E67E22' \
        --prompt '> ' \
        --reverse \
        --height "100%" \
        --preview 'bat --style=changes --color=always {}' \
        --preview-window 'right:70%:wrap:noinfo' \
        --bind 'ctrl-u:preview-half-page-up' \
        --bind 'ctrl-d:preview-half-page-down' \
]]

local float_design = {
    style = "minimal",
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines - 2, -- Don't cover status bar
    row = 0,
    col = 0,
    border = "none",
}

local function start_fzf(picker, default, fzf_extra, edit_func)
    vim.env.FZF_DEFAULT_OPTS = nil

    fzf_extra = fzf_extra or ""
    edit_func = edit_func or function(selection)
        vim.cmd("e " .. selection)
    end

    -- Generate temp file for fzf selection
    local temp_file = vim.fn.tempname()

    vim.fn.jobstart(
        picker .. "|" .. default .. fzf_extra .. ">" .. temp_file, {
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
    local buf = vim.api.nvim_create_buf(false, true)

    float_design.width = vim.o.columns
    float_design.height = vim.o.lines - 2

    vim.api.nvim_open_win(buf, true, float_design)
end

local function find_files()
    open_term_win()
    start_fzf("rg --files --hidden", fzf_default)
end

local function edit_nexus()
    open_term_win()
    start_fzf("rg --hidden --files ~/Nexus", fzf_default)
end

local function edit_dotfiles()
    open_term_win()
    start_fzf("rg --hidden --files ~/dotfiles", fzf_default)
end

local function live_grep()
    local grep_fzf_default = [[
            : | rg_prefix='rg --column --hidden --line-number --no-heading --color=always --smart-case' \
            fzf --bind 'start:reload:${=rg_prefix} ""' \
                --bind 'change:reload:${=rg_prefix} {q} || true' \
                --ansi \
                --delimiter : \
                --disabled \
                --height=100% \
                --layout=reverse \
                --color 'pointer:#E67E22,prompt:#E67E22' \
                --prompt '> ' \
                --preview 'bat --style=plain --color=always {1} --highlight-line {2}' \
                --preview-window 'right:70%:noinfo:+{2}/2' \
                --bind 'ctrl-u:preview-half-page-up' \
                --bind 'ctrl-d:preview-half-page-down' \
    ]]

    open_term_win()
    start_fzf("ls", grep_fzf_default, nil, function(selection)
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
    start_fzf(gs_picker, fzf_default, fzf_extra, function(selected)
        vim.cmd("e " .. git_root .. "/" .. selected)
    end)
end

-- FEATURES
--
-- See this for inspiration
-- sh -c "$(curl -s https://raw.githubusercontent.com/ibhagwan/fzf-lua/main/scripts/mini.sh)"
--
-- Dev-icon support

-- COMMANDS

-- buffers
-- files from path (visual selection?)
-- quickfix list
-- marks
-- treesitter
--
-- FOR GREPPING look into the builtin lgrep command
--
-- grep_cword    search word under cursor
-- grep_cWORD   search WORD under cursor
-- grep_visual  search visual selection
--
-- lsp references (vim.lsp.buf.references())
-- lsp_definitions
-- lsp_declarations
--
-- colorschemes
-- highlight groups
--
-- neovim commands
-- neovim options
-- key mappings
--
-- location list and quick fix list
--
-- man pages
-- neovim help files

vim.keymap.set("n", "<leader>fd", find_files, {})
vim.keymap.set("n", "<leader>en", edit_dotfiles, {})
vim.keymap.set("n", "<leader>eo", edit_nexus, {})
vim.keymap.set("n", "<leader>gf", live_grep, {})
vim.keymap.set("n", "<leader>gs", git_status, {})
