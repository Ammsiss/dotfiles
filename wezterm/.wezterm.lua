local wez = require("wezterm")
local hostname = wez.hostname()

local function getFontSize()
    if hostname == "Junjis-MacBook-Air.local" then
        return 21
    elseif hostname == "Junjis-Mac-mini.local" then
        return 20
    elseif hostname == "fedora" then -- bug, hostname not fedora
        return 20
    else
        return 18
    end
end

local function getDecoration()
    if hostname == "Junjis-MacBook-Air.local" then
        return "RESIZE"
    elseif hostname == "Junjis-Mac-mini.local" then
        return "RESIZE"
    else
        return "NONE"
    end
end

return {
    audible_bell = "Disabled",
    color_scheme = "GruvboxDark",
    font = wez.font("FiraCode Nerd Font"),
    font_size = getFontSize(),
    window_background_opacity = 1.0,
    cursor_blink_rate = 0,
    window_decorations = getDecoration(),
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    default_cursor_style = "SteadyBar",
    colors = {
        cursor_bg = "#E67E22",
        cursor_fg = "#1d6d6e",
        cursor_border = "#ebdbb2",
    },
    keys = {
    }
}
