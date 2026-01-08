-- Create api that converst fzf options into a programmaable data.
-- Custom previewer that can be a neovim buffer

local fzf_default = [[
    fzf \
        --color 'pointer:#E67E22,prompt:#E67E22' \
        --prompt '> ' \
        --reverse \
        --ansi \
        --height "100%" \
        --preview 'bat --style=grid,header-filename --color=always {2}' \
        --accept-nth 2 \
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

    local bufnr = vim.api.nvim_get_current_buf()

    vim.env.FZF_DEFAULT_OPTS = nil

    fzf_extra = fzf_extra or ""
    edit_func = edit_func or function(selection)
        vim.cmd("e " .. selection)
    end

    -- Generate temp file for fzf selection
    local temp_file = vim.fn.tempname()

    local term_dead = false

    vim.fn.jobstart(
        picker .. "|" .. default .. fzf_extra .. ">" .. temp_file, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local fd = io.open(temp_file, "r")
                    if fd then
                        local selection = fd:read("*l")
                        fd:close()

                        if not term_dead then
                            term_dead = true
                            vim.api.nvim_buf_delete(bufnr, { force = true })
                        end

                        edit_func(selection)
                    end
                else
                    if not term_dead then
                        term_dead = true
                        vim.api.nvim_buf_delete(bufnr, { force = true })
                    end
                end
            end
        }
    )

    vim.api.nvim_feedkeys("i", "n", false)

    vim.keymap.set("t", "<ESC>", function()
        if not term_dead then
            term_dead = true
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end, { buffer = bufnr })
end

local function open_term_win()
    local buf = vim.api.nvim_create_buf(false, true)

    float_design.width = vim.o.columns
    float_design.height = vim.o.lines - 2

    vim.api.nvim_open_win(buf, true, float_design)
end

local function colorize_hex(text, hex)
  hex = hex:gsub("^#", "")
  assert(#hex == 6, "hex color must be RRGGBB")

  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  local ansi_start = string.format("\27[38;2;%d;%d;%dm", r, g, b)
  local ansi_reset = "\27[0m"

  return ansi_start .. text .. ansi_reset
end

local function add_devicons(obj)
    local items = vim.split(obj.stdout, "\n", { trimempty = true })

    for i, item in ipairs(items) do
        vim.fs.basename(item)
        local icon, color_code = require("nvim-web-devicons").get_icon_color(
            vim.fs.basename(item), nil, { default = true })

        items[i] = colorize_hex(icon, color_code) .. " " .. item
    end

    local fzf_input = ""
    for _, item in ipairs(items) do
        fzf_input = fzf_input .. item .. "\n"
    end

    return fzf_input
end

local function find_files()
    open_term_win()

    local fzf_input = add_devicons(vim.system(
        { "rg", "--files", "--hidden", "-L" }, {}):wait())

    start_fzf("echo -n \"" .. fzf_input .. "\"", fzf_default)
end

local function edit_nexus()
    open_term_win()

    local home = vim.loop.os_homedir()
    local rg_cmd = { "rg", "--files", "--hidden", home .. "/Nexus" }
    local fzf_input = add_devicons(vim.system(rg_cmd, {}):wait())

    start_fzf("echo -n \"" .. fzf_input .. "\"", fzf_default)
end

local function edit_dotfiles()
    open_term_win()

    local home = vim.loop.os_homedir()
    local rg_cmd = { "rg", "--files", "--hidden", home .. "/dotfiles" }
    local fzf_input = add_devicons(vim.system(rg_cmd, {}):wait())

    start_fzf("echo -n \"" .. fzf_input .. "\"", fzf_default)
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

    local rg_cmd = { "git", "diff", "--name-only", "--diff-filter=ACMRT", "HEAD" }
    local fzf_input = add_devicons(vim.system(rg_cmd, {}):wait())

    local fzf_extra =
        "--preview='repo=" .. git_root ..
       [[; bat --style=changes --color=always "$repo"/{2}' ]]

    open_term_win()
    start_fzf("echo -n \"" .. fzf_input .. "\"", fzf_default, fzf_extra, function(selected)
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
