local function open(title, command, path)

    local buf = vim.api.nvim_create_buf(false, true)

    local width = vim.o.columns - 20
    local height = vim.o.lines - 6 - 3
    local design = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2 - 2,
        col = (vim.o.columns - width) / 2,
        title = title,
        title_pos = "center",
        border = "rounded",
    }

    vim.api.nvim_open_win(buf, true, design)

    vim.fn.jobstart(command, {
            term = true,
            on_exit = function(_, exit_code, _)

                if exit_code == 0 then
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
                    vim.cmd("close")
                    vim.cmd("e " .. path .. lines[1])
                else
                    vim.cmd("close")
                end

            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
end

vim.keymap.set("n", "<leader>fd", function()
    open("  File Search  ",
    [[
        gfind \( -path '*/.git' -o -path '*/node_modules' \) -prune -false -o -type f ! -name .DS_Store -printf '%P\n' | \

        fzf --color=pointer:#006c7a,prompt:#FFA500 --prompt="> " --layout=reverse --preview 'bat --style=changes --color=always {}' \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], vim.fn.getcwd() .. "/")
end, { silent = true })

vim.keymap.set("n", "<leader>fs", function()
    local handle = io.popen("git rev-parse --show-toplevel 2> /dev/null")
    local git_root
    if handle then
        git_root = handle:read("*a"):gsub("%s+$", "")
        handle:close()
    end

    open("  Git Changes  ",
    [[
        git diff --name-only --diff-filter=ACMRT | \
        fzf --color=pointer:#006c7a,prompt:#FFA500 --prompt="> " --layout=reverse \
        --preview='
        repo=$(git rev-parse --show-toplevel)
        bat --style=changes --color=always "$repo"/{}
        ' \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], git_root .. "/")
end, { silent = true })

vim.keymap.set("n", "<leader>en", function()
    open(" Edit Dotfiles ",
    [[
        gfind /Users/ammsiss/dotfiles \( -path '*/.git' -o -path '*/node_modules' \) -prune -false -o -type f ! -name .DS_Store -print | \

        fzf --color=pointer:#006c7a,prompt:#FFA500 \
            --prompt="> " \
            --layout=reverse \
            --preview 'bat --style=changes --color=always {}' \
            --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], "")
end, { silent = true })

vim.keymap.set("n", "<leader>fg", function()
    open(" Live Grep ",
    [[
        RG_CMD='grep -rn --color=always'
        BAT_CMD='
            file=$(echo {} | cut -d":" -f1)
            line=$(echo {} | cut -d":" -f2)

            start=$(( line - 20 )); [ $start -lt 1 ] && start=1
            end=$(( line + 20 ))

            bat --color=always --style=changes \
                --line-range "$start:$end" \
                --highlight-line "$line" "$file"
        ' \

        fzf --ansi \
            --layout=reverse \
            --disabled \
            --phony \
            --color=pointer:#006c7a,prompt:#FFA500 \
            --prompt '> ' \
            --delimiter : \
            --preview $BAT_CMD \
            --bind "start:reload:echo" \
            --bind "change:reload:(test -n '{q}' && $RG_CMD '{q}') || true"
    ]])
end, { silent = true })
