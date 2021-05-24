-- anon, awesome3 theme

--{{{ Main
local awful = require("awful")
awful.util = require("awful.util")

local gfs = require("gears.filesystem")
local default_theme_path = gfs.get_themes_dir() .. "/default/"

theme = {}

--}}}

theme.font                     = "Iosevka Term SS09 13"
theme.hotkeys_font             = "Iosevka Term SS09 17"
theme.hotkeys_description_font = "Iosevka Term SS09 17"

theme.hotkeys_bg               = "#dddddd"

theme.bg_normal     = "#252525"
theme.bg_focus      = "#252525"
theme.bg_urgent     = "#ff0000"

theme.fg_normal     = "#888888"
theme.fg_focus      = "#dddddd"
theme.fg_urgent     = "#ffffff"

theme.border_width  = 1
theme.border_normal = "#444444"
theme.border_focus  = "#888888"
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
theme.useless_gap = 15

-- Icons
theme.icon_theme = 'Papirus-Dark'

theme.layout_fairh      = default_theme_path.."layouts/fairhw.png"
theme.layout_fairv      = default_theme_path.."layouts/fairvw.png"
theme.layout_floating   = default_theme_path.."layouts/floatingw.png"
theme.layout_magnifier  = default_theme_path.."layouts/magnifierw.png"
theme.layout_max        = default_theme_path.."layouts/maxw.png"
theme.layout_fullscreen = default_theme_path.."layouts/fullscreenw.png"
theme.layout_tilebottom = default_theme_path.."layouts/tilebottomw.png"
theme.layout_tileleft   = default_theme_path.."layouts/tileleftw.png"
theme.layout_tile       = default_theme_path.."layouts/tilew.png"
theme.layout_tiletop    = default_theme_path.."layouts/tiletopw.png"
theme.layout_spiral     = default_theme_path.."layouts/spiralw.png"
theme.layout_dwindle    = default_theme_path.."layouts/dwindlew.png"
theme.layout_cornernw   = default_theme_path.."layouts/cornernww.png"
theme.layout_cornerne   = default_theme_path.."layouts/cornernew.png"
theme.layout_cornersw   = default_theme_path.."layouts/cornersww.png"
theme.layout_cornerse   = default_theme_path.."layouts/cornersew.png"

-- Default master width
theme.master_width_factor = 0.7

-- Menu
theme.menu_width = 200

-- Wibar
theme.wibar_height = 16

return theme
