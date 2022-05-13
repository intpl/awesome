local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
-- awesome buttons
local awesomebuttons = require("awesome-buttons.awesome-buttons")

local my_top_bar = {}

function my_top_bar.attach_to_screen(s)
  -- Don't add desktop buttons if on laptop
  if mouse.screen.geometry.width <= 1920 then return end;

  local my_right_desktop_buttons = wibox {
    visible = true,
    max_widget_size = 500,
    height = 40,
    width = 400,
    type = "dock",
  }

  my_right_desktop_buttons:setup {
    {
      {
        {
          awesomebuttons.with_icon_and_text{ type = 'outline', icon = 'plus', text = '<span color="#fff">clients</span>', color = '#040', icon_size = 16, onclick = function()
                                               awful.tag.incnmaster( 1, nil, true)
          end},
          awesomebuttons.with_icon_and_text{ type = 'outline', icon = 'minus', text = '<span color="#fff">clients</span>', color = '#400', icon_size = 16, onclick = function()
                                               awful.tag.incnmaster(-1, nil, true)
          end},
          wibox.widget{markup = ' / ', widget = wibox.widget.textbox},
          awesomebuttons.with_icon_and_text{ type = 'outline', icon = 'plus', text = '<span color="#fff">columns</span>', color = '#040', icon_size = 16, onclick = function()
                                               awful.tag.incncol(1, nil, true)
          end},
          awesomebuttons.with_icon_and_text{ type = 'outline', icon = 'minus', text = '<span color="#fff">columns</span>', color = '#400', icon_size = 16, onclick = function()
                                               awful.tag.incncol(-1, nil, true)
          end},
          s.mylayoutbox,
          spacing = 0,
          layout = wibox.layout.fixed.horizontal
        },
        spacing = 2,
        layout = wibox.layout.fixed.vertical,
      },
      shape_border_width = 1,
      valigh = 'center',
      layout = wibox.container.place
    },
    margins = 0,
    widget = wibox.container.margin
  }

  my_right_desktop_buttons:connect_signal("mouse::enter", function(c) c.ontop = true end)
  my_right_desktop_buttons:connect_signal("mouse::leave", function(c) c.ontop = false end)

  awful.placement.top_right(my_right_desktop_buttons, { margins = {top = -10, right = 150}, parent = s})
  -- https://awesomewm.org/doc/api/classes/awful.widget.only_on_screen.html
end

return my_top_bar
