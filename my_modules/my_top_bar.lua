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

local function shrink_left()
  local tags = my_tag_expander.sorted_tags()
  if #tags > 1 then awful.tag.viewtoggle(tags[1]) end -- 1-indexed arrays lol
end

local function shrink_right()
  local tags = my_tag_expander.sorted_tags()
  if #tags > 1 then awful.tag.viewtoggle(tags[#tags]) end
end

function my_top_bar.attach_to_screen(s)
  -- Don't add desktop buttons if on laptop
  if s.geometry.width <= 1920 then return end;

  local default_opacity = 0.05

  local my_right_desktop_buttons = wibox {
    visible = true,
    height = 50,
    width = 882,
    opacity = default_opacity,
    type = "dock",
  }

  -- feathericons.com

  my_right_desktop_buttons:setup {
    {
      {
        {
          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'refresh-ccw',
                                             text = '<span color="#fff">tag</span>',
                                             color = '#444',
                                             icon_size = 24,
                                             onclick = function() awful.tag.history.restore() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'arrow-up-left',
                                             text = '<span color="#fff">exp</span>',
                                             color = '#444',
                                             icon_size = 24,
                                             onclick = function() expand_left() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'arrow-up-right',
                                             text = '<span color="#fff">exp</span>',
                                             color = '#444',
                                             icon_size = 24,
                                             onclick = function() expand_right() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'arrow-down-right',
                                             text = '<span color="#fff">shr</span>',
                                             color = '#444',
                                             icon_size = 24,
                                             onclick = function() shrink_left() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'arrow-down-left',
                                             text = '<span color="#fff">shr</span>',
                                             color = '#444',
                                             icon_size = 24,
                                             onclick = function() shrink_right() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'crop',
                                             text = '<span color="#fff">mfpol</span>',
                                             color = '#400',
                                             icon_size = 24,
                                             onclick = function() awful.tag.togglemfpol() end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'plus',
                                             text = '<span color="#fff">cli</span>',
                                             color = '#040',
                                             icon_size = 24,
                                             onclick = function() awful.tag.incnmaster( 1, nil, true) end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'minus',
                                             text = '<span color="#fff">cli</span>',
                                             color = '#400',
                                             icon_size = 24,
                                             onclick = function() awful.tag.incnmaster(-1, nil, true) end},

          -- wibox.widget{markup = ' / ', widget = wibox.widget.textbox},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'plus',
                                             text = '<span color="#fff">col</span>',
                                             color = '#040',
                                             icon_size = 24,
                                             onclick = function() awful.tag.incncol(1, nil, true) end},

          awesomebuttons.with_icon_and_text{ type = 'basic',
                                             icon = 'minus',
                                             text = '<span color="#fff">col</span>',
                                             color = '#400',
                                             icon_size = 24,
                                             onclick = function() awful.tag.incncol(-1, nil, true) end},
          s.mylayoutbox,
          spacing = 3,
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

  my_right_desktop_buttons:connect_signal("mouse::enter", function(c) c.opacity = 0.99 c.ontop = true end)
  my_right_desktop_buttons:connect_signal("mouse::leave", function(c) c.opacity = default_opacity c.ontop = false end)

  awful.placement.top_right(my_right_desktop_buttons, { margins = {top = -2, right = 50}, parent = s})
end

return my_top_bar
