local awful = require("awful")

local function tag_right_index(tags) return tags[#tags].index + 1 end
local function tag_left_index(tags) return tags[1].index - 1 end
local function can_focus_tag_right(tags) if  tag_right_index(tags) <= 9 then return true else return false end end
local function can_focus_tag_left(tags) if tag_left_index(tags) >= 1 then return true else return false end end
local function focus_tag_right(tags) awful.tag.viewtoggle(awful.screen.focused().tags[tag_right_index(tags)]) end
local function focus_tag_left(tags) awful.tag.viewtoggle(awful.screen.focused().tags[tag_left_index(tags)]) end
local function sorted_tags()
  local tags = awful.screen.focused().selected_tags
  table.sort(tags, function(a,b) return a.index < b.index end)

  return tags
end

local my_tag_expander = {
  sorted_tags = sorted_tags,
  can_focus_tag_right = can_focus_tag_right,
  can_focus_tag_left = can_focus_tag_left,
  focus_tag_right = focus_tag_right,
  focus_tag_left = focus_tag_left
}

function my_tag_expander.from_left()
    local tags = sorted_tags()
    if #tags == 9 then return end

    if tags[1].index == 1 or #tags % 2 == 0 and can_focus_tag_right(tags) then focus_tag_right(tags)
    else focus_tag_left(tags) end
end

function my_tag_expander.from_right()
    local tags = sorted_tags()
    if #tags == 9 then return end

    if tags[#tags].index == 9 or #tags % 2 == 0 and can_focus_tag_left(tags) then focus_tag_left(tags)
    else focus_tag_right(tags) end
end

return my_tag_expander
