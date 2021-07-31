local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local my_transparency_mode = {is_enabled = false}
local opacity_value = 0.8

function enable_transparency_mode()
  for _, c in pairs(client.get()) do
    if c.focused then
      c.opacity=1
    else
      c.opacity=opacity_value
    end

  end

  beautiful.border_width=0
  my_transparency_mode.is_enabled = true
end

function disable_transparency_mode()
  for _, c in pairs(client.get()) do
    c.opacity=1
  end

  beautiful.border_width=1
  my_transparency_mode.is_enabled = false
end

function markup()
  if my_transparency_mode.is_enabled then
    return ' <span color="#ffffff">transparency</span> '
  else
    return ' transparency '
  end
end

function my_transparency_mode.focus(c)
  if my_transparency_mode.is_enabled then c.opacity=1 end
  c.border_color = beautiful.border_focus
end

function my_transparency_mode.unfocus(c)
  if my_transparency_mode.is_enabled then c.opacity=opacity_value end
  c.border_color = beautiful.border_normal
end

function my_transparency_mode.toggle()
  if my_transparency_mode.is_enabled then disable_transparency_mode() else enable_transparency_mode() end

  my_transparency_mode.widget:set_markup_silently(markup())
end

my_transparency_mode.widget = wibox.widget{markup = markup(), widget = wibox.widget.textbox}
my_transparency_mode.widget:connect_signal("button::press", function() my_transparency_mode.toggle() end)

return my_transparency_mode
