local M = {}

function M.feedkeys(cmd)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
            cmd, true, false, true
        ),
        "n",
        true
    )
end

function M.get_temp()
    local temp_dir = vim.fn.stdpath("data") .. "/temp"
    if vim.fn.isdirectory(temp_dir) == 0 then
        vim.fn.mkdir(temp_dir, "p")
    end

    return temp_dir .. "/temp-" .. vim.fn.getpid() .. ".txt"
end

function M.set(lhs, rhs, mode, opts)
    local default_opts = { noremap = true, silent = true }

    mode = mode or "n"
    opts = vim.tbl_extend("force", default_opts, opts or {})

    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.new_wait_group(on_done)
    return {
        count = 0,
        done = false,
        on_done = on_done,
        add = function(self, n)
            self.count = self.count + (n or 1)
        end,
        finish = function(self)
            self.count = self.count - 1
            if self.count <= 0 and not self.done then
                self.done = true
                vim.schedule(self.on_done)
            end
        end
    }
end

function M.create_float_win()
    local float_design = {
        style = "minimal",
        relative = "editor",
        width = vim.o.columns,
        height = vim.o.lines - 2, -- Don't cover status bar
        row = 0,
        col = 0,
        border = "none",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    local win = vim.api.nvim_open_win(buf, true, float_design)

    return win, buf
end

return M
