local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local my_minimal_mode = {is_enabled = false}

function enable_minimal_mode()
  -- hide all titlebars
  for _, c in pairs(client.get()) do awful.titlebar.hide(c) end

  -- disable useless gaps
  for _, t in pairs(root.tags()) do t.gap = 0 end

  -- expand master_fill_policy
  -- beautiful.master_fill_policy = 'expand'

  my_minimal_mode.is_enabled = true
end

function disable_minimal_mode()
  -- show titlebars for unmaximized clients
  for _, c in pairs(client.get()) do
    if not c.maximized and c.instance ~= "conky" then
      awful.titlebar.show(c)
    end
  end

  -- enable useless gaps
  for _, t in pairs(root.tags()) do t.gap = beautiful.useless_gap end

  -- reset master_fill_policy
  -- beautiful.master_fill_policy = 'master_width_factor'

  my_minimal_mode.is_enabled = false
end

function my_minimal_mode.markup()
  if my_minimal_mode.is_enabled then
    return ' <span color="#ffffff">minimal</span> '
  else
    return ' minimal '
  end
end

function my_minimal_mode.toggle()
  if my_minimal_mode.is_enabled then disable_minimal_mode() else enable_minimal_mode() end

  my_minimal_mode.widget:set_markup_silently(my_minimal_mode.markup())
end

my_minimal_mode.widget = wibox.widget{markup = my_minimal_mode.markup(), widget = wibox.widget.textbox}
my_minimal_mode.widget:connect_signal("button::press", function() my_minimal_mode.toggle() end)

return my_minimal_mode
