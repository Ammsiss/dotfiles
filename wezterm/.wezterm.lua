local wez = require("wezterm")

local function getFontSize()
    if wez.hostname() == "Junjis-MacBook-Air.local" then
        return 17
    else
        return 20
    end
end

return {
    color_scheme = "GruvboxDark",
    font = wez.font("FiraCode Nerd Font"),
    font_size = getFontSize(),
    window_background_opacity = 0.55,
    cursor_blink_rate = 0,
    window_decorations = "RESIZE",
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    default_cursor_style = "SteadyBar",
    colors = {
        cursor_bg = "#E67E22",
        cursor_fg = "#ebdbb2",
        cursor_border = "#ebdbb2",
    },
}
