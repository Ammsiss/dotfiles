vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "markdown",
    callback = function(opts)

        -- BLOCK QUOTES

        local blockquote_query = vim.treesitter.query.parse("markdown", "((block_quote_marker) @str)")
        local blockquote_cont_query = vim.treesitter.query.parse("markdown",
            "((block_continuation) @str (#has-ancestor? @str block_quote))")

        local function refresh_blockquote(bufnr, mark_ns, tree)
            bufnr = bufnr or 0

            for _, node, _, _ in blockquote_query:iter_captures(tree:root(), bufnr) do
                local sl, sc, _, _ = node:range()

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
                    { hl_group = "MyMarkupBlue", end_col = sc + 1, conceal = "▉" })
            end

            for _, node, _, _ in blockquote_cont_query:iter_captures(tree:root(), bufnr) do
                local sl, sc, _, _ = node:range()

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
                    { hl_group = "MyMarkupBlue", end_col = sc + 1, conceal = "▉" })
            end
        end

        -- CHECKBOX

        local checked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_checked) @str)")
        local unchecked_query = vim.treesitter.query.parse("markdown", "((task_list_marker_unchecked) @str)")
        local check_marker_query = vim.treesitter.query.parse("markdown",
            "(list_item (list_marker_minus) @task_bullet [(task_list_marker_unchecked) (task_list_marker_checked)])")

        local function refresh_checkbox(bufnr, mark_ns, tree)
            bufnr = bufnr or 0

            for _, node, _, _ in checked_query:iter_captures(tree:root(), bufnr) do
                local sl, sc, _, ec = node:range()

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
                    { hl_group = "MyMarkupPurple", end_col = ec, conceal = "☑" })
            end

            for _, node, _, _ in unchecked_query:iter_captures(tree:root(), bufnr) do
                local sl, sc, _, ec = node:range()

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
                    { hl_group = "MyMarkupPurple", end_col = ec, conceal = "☐" })
            end

            for _, node, _, _ in check_marker_query:iter_captures(tree:root(), bufnr) do
                local sl, sc, _, ec = node:range()

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc,
                    { hl_group = "MyMarkupPurple", end_col = ec, conceal = "" })
            end
        end

        -- LIST

        local bullet_query = vim.treesitter.query.parse("markdown", "((list_marker_minus) @minus)")
        local bulletn1_query = vim.treesitter.query.parse("markdown",
            "(list (list_item (list (list_item (list_marker_minus) @nested_minus))))")
        local bulletn2_query = vim.treesitter.query.parse("markdown",
            "(list (list_item (list (list_item (list (list_item (list_marker_minus) @nested_minus))))))")

        local function refresh_lists(bufnr, mark_ns, tree)
            bufnr = bufnr or 0

            for _, node, _, _ in bullet_query:iter_captures(tree:root(), bufnr) do
                local sl, _, _, ec = node:range()

                local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
                local dash_index = string.find(line, "-")

                if dash_index then
                    vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
                        { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "●", priority = 0 })
                end
            end

            for _, node, _, _ in bulletn1_query:iter_captures(tree:root(), bufnr) do
                local sl, _, _, ec = node:range()

                local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
                local dash_index = string.find(line, "-")

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
                    { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "◐", priority = 10 })
            end

            for _, node, _, _ in bulletn2_query:iter_captures(tree:root(), bufnr) do
                local sl, _, _, ec = node:range()

                local line = vim.api.nvim_buf_get_text(bufnr, sl, 0, sl, ec, {})[1]
                local dash_index = string.find(line, "-")

                vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, dash_index - 1,
                    { hl_group = "MyMarkupOrange", end_col = ec - 1, conceal = "◑", priority = 20 })
            end
        end

        -- HEADER RENDERING

        local header_node_names = {
            "atx_h1_marker", "atx_h2_marker", "atx_h3_marker", "atx_h4_marker",
            "atx_h5_marker", "atx_h6_marker"
        }

        local header_queries = {}
        for _, name in ipairs(header_node_names) do
            local query_str = "((" .. name .. ") @str)"
            table.insert(header_queries, vim.treesitter.query.parse('markdown', query_str))
        end

        local header_conceal_chars = { "①", "②", "③", "④", "⑤", "⑥" }

        local function refresh_header(bufnr, mark_ns, tree)
            bufnr = bufnr or 0

            local sign_colors = {
                "MyMarkupYellow",
                "MyMarkupGreen",
                "MyMarkupPurple",
                "MyMarkupRed",
                "MyMarkupOrange",
                "MyMarkupBlue",
            }

            for i, query in ipairs(header_queries) do
                for _, node, _, _ in query:iter_captures(tree:root(), bufnr) do

                    local sl, sc, _, ec = node:range()
                    local hl = "MyMarkupHeading" .. i

                    vim.api.nvim_buf_set_extmark(bufnr, mark_ns, sl, sc, {
                        hl_group = hl, end_col = ec, conceal = header_conceal_chars[i],
                        sign_text = "⇒", sign_hl_group = sign_colors[i]
                    })
                end
            end
        end

        local function refresh(buf)
            vim.schedule(function()
                local mark_ns = vim.api.nvim_create_namespace('MarkdownRendering')
                vim.api.nvim_buf_clear_namespace(buf, mark_ns, 0, -1)

                local parser = vim.treesitter.get_parser(buf, "markdown")
                assert(parser) -- Throws error anyway but silences lls

                local tree = parser:parse()[1]

                refresh_header(buf, mark_ns, tree)
                refresh_checkbox(buf, mark_ns, tree)
                refresh_blockquote(buf, mark_ns, tree)
                refresh_lists(buf, mark_ns, tree)
            end)
        end

        refresh(opts.buf)

        -- vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP"  }, {
        --     buffer = 0,
        --     callback = function()
        --         refresh(0)
        --     end
        -- })
    end
})
