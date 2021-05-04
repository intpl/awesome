-- anon, awesome3 theme

--{{{ Main
local awful = require("awful")
awful.util = require("awful.util")

theme = {}

--}}}

theme.font          = "Iosevka Term SS09 13"

theme.bg_normal     = "#252525"
theme.bg_focus      = "#252525"
theme.bg_urgent     = "#ff0000"

theme.fg_normal     = "#555555"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"

theme.border_width  = 1
theme.border_normal = "#444444"
theme.border_focus  = "#aaaaaa"
theme.border_marked = "#91231c"

-- Display the taglist squares
theme.taglist_squares = true

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--bg_widget    = #cc0000

-- Display close button inside titlebar
theme.titlebar_close_button = true
theme.tasklist_disable_icon = true

-- Gaps
theme.gap_single_client = true
theme.useless_gap = 5

-- Icons

theme.icon_theme = 'Papirus-Dark'

-- Default master width
theme.master_width_factor = 0.7

return theme
