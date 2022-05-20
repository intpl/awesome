local awful = require("awful")
local wibox = require("wibox")

local my_mfpol_toggler = {}

my_mfpol_toggler.widget = wibox.widget{markup = ' mfpol ', widget = wibox.widget.textbox}
my_mfpol_toggler.widget:connect_signal("button::press", function() awful.tag.togglemfpol() end)

return my_mfpol_toggler
