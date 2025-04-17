local wez = require("wezterm")

return {
    color_scheme = "GruvboxDark",
    font = wez.font("FiraCode Nerd Font"),
    font_size = 20,
    window_background_opacity = 0.55,
    cursor_blink_rate = 0,
    window_decorations = "RESIZE",
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    default_cursor_style = "SteadyBar",
    colors = {
        cursor_bg = "#1d6d6e",     -- bright green cursor
        cursor_fg = "#ebdbb2",     -- black text under the cursor
        cursor_border = "#ebdbb2", -- match cursor outline
    },
}
