local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
-- awesome buttons
local awesomebuttons = require("awesome-buttons.awesome-buttons")
local my_tag_expander = require("my_modules.my_tag_expander")

local my_top_bar = {}

local function expand_left()
  local tags = my_tag_expander.sorted_tags()

  if my_tag_expander.can_focus_tag_left(tags) then
    my_tag_expander.focus_tag_left(tags)
  end
end

local function expand_right()
  local tags = my_tag_expander.sorted_tags()

  if my_tag_expander.can_focus_tag_right(tags) then
    my_tag_expander.focus_tag_right(tags)
  end
end

function my_top_bar.attach_to_screen(s)
  -- Don't add desktop buttons if on laptop
  if s.geometry.width <= 1920 then return end;

  local my_right_desktop_buttons = wibox {
    visible = true,
    height = 30,
    width = 660,
    type = "dock",
  }

  my_right_desktop_buttons:setup {
    {
      {
        {
          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'arrow-left',
                                             text = '<span color="#fff">left</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() awful.tag.viewprev(s) end},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'arrow-right',
                                             text = '<span color="#fff">right</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() awful.tag.viewnext(s) end},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'arrow-up-left',
                                             text = '<span color="#fff">expand</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() expand_left() end},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'arrow-up-right',
                                             text = '<span color="#fff">expand</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() expand_right() end},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'plus',
                                             text = '<span color="#fff">clients</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() awful.tag.incnmaster( 1, nil, true) end},
          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'minus',
                                             text = '<span color="#fff">clients</span>',
                                             color = '#400',
                                             icon_size = 16,
                                             onclick = function() awful.tag.incnmaster(-1, nil, true) end},

          -- wibox.widget{markup = ' / ', widget = wibox.widget.textbox},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'plus',
                                             text = '<span color="#fff">columns</span>',
                                             color = '#040',
                                             icon_size = 16,
                                             onclick = function() awful.tag.incncol(1, nil, true) end},

          awesomebuttons.with_icon_and_text{ type = 'outline',
                                             icon = 'minus',
                                             text = '<span color="#fff">columns</span>',
                                             color = '#400',
                                             icon_size = 16,
                                             onclick = function() awful.tag.incncol(-1, nil, true) end},

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

  my_right_desktop_buttons:connect_signal("mouse::enter", function(c)
                                            c.opacity = 0.99
                                            c.ontop = true
  end)
  my_right_desktop_buttons:connect_signal("mouse::leave", function(c)
                                            c.opacity = 0.3
                                            c.ontop = false
  end)

  awful.placement.top_right(my_right_desktop_buttons, { margins = {top = -2, right = 50}, parent = s})
end

return my_top_bar
