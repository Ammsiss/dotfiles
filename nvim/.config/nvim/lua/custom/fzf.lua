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
    }

    vim.api.nvim_open_win(buf, true, design)

    vim.fn.jobstart(command, {
            term = true,
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
                    vim.cmd("close")
                    vim.cmd("e " .. path .. lines[1])
                end
            end
        }
    )
    vim.api.nvim_feedkeys("i", "n", false)
end

vim.keymap.set("n", "<leader>fd", function()
    open(" :-D File Search :-D ",
    [[
        gfind -type f -printf '%P\n' | \
        fzf --layout=reverse --preview 'bat --style=header,grid,changes,numbers --color=always {}' \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], vim.fn.getcwd() .. "/")
end, { silent = true })

vim.keymap.set("n", "<leader>fs", function()
    open(" :-D Edit Neovim :-D ",
    [[
        git diff --name-only --diff-filter=ACMRT | \
        fzf --layout=reverse \
        --preview='
        repo=$(git rev-parse --show-toplevel)
        bat --style=header,grid,changes --color=always "$repo"/{}
        ' \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], "")
end, { silent = true })

vim.keymap.set("n", "<leader>en", function()
    open(" :-D Edit Neovim :-D ",
    [[
        gfind /Users/ammsiss/dotfiles/nvim/.config/nvim -type f | \
        fzf --layout=reverse --preview 'bat --style=header,grid,changes,numbers --color=always {}' \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]], "")
end, { silent = true })

vim.api.nvim_create_user_command("Fg", function(args)

    if args.fargs[1] == "" or args.fargs[1] == nil then
        print("Invalid search term")
        return
    end

    open(" :-D Grep :-D ",
    [[
        grep -rn --color=always ]] .. args.fargs[1] .. [[ . | sed 's|^\./||' | \
        fzf --ansi \
            --preview='
                file=$(echo {} | cut -d":" -f1)
                line=$(echo {} | cut -d":" -f2)

                # 15‑line window, clamped to the top of the file
                start=$(( line - 15 )); [ $start -lt 1 ] && start=1
                end=$(( line + 15 ))

                bat --color=always --style=header,grid,changes,numbers \
                    --line-range "$start:$end" \
                    --highlight-line "$line" "$file"
            ' \
            --layout=reverse \
            --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down
    ]])
end, { nargs = "?" })
