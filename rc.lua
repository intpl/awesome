-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
naughty.config.defaults.position = "bottom_right"

local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- awesome-wm-widgets
local battery_widget = require("awesome-wm-widgets.battery-widget.battery") -- icons: https://github.com/horst3180/arc-icon-theme
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify") -- install `sp` tool: https://gist.github.com/fa6258f3ff7b17747ee3.git

-- calendar from https://github.com/deficient/calendar
local calendar = require("calendar")

-- My Modules
local my_minimal_mode = require('my_modules.my_minimal_mode')
local my_tag_expander = require('my_modules.my_tag_expander')
local my_top_bar = require('my_modules.my_top_bar') -- requires 'awesomebuttons'

local toggle_useless_gaps_and_mfpol = function()
    local selected_tag = awful.screen.focused().selected_tag

    if selected_tag.gap ~= 30 then
        selected_tag.gap = 30
        if selected_tag.index ~= 1 then
            selected_tag.master_fill_policy = "master_width_factor"
        end
    else
        selected_tag.gap = 2
        selected_tag.master_fill_policy = "expand"
    end

    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
end

local remove_useless_gaps = function()
    t = awful.screen.focused().selected_tag
    t.gap = 0

    if t.master_fill_policy == "master_width_factor" then
        awful.tag.togglemfpol()
    end

    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
end

local toggle_even_split = function()
    local selected_tag = awful.screen.focused().selected_tag

    if selected_tag.master_width_factor ~= 0.5 then
        selected_tag.master_width_factor = 0.5
    else
        selected_tag.master_width_factor = 0.7
    end

    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
end

local myviewnext = function(screen)
    local t = awful.screen.focused().selected_tags[1]
    local original_t_index = t.index

    if t ~= nil then
        repeat
            t = awful.screen.focused().tags[(t.index % 9) + 1]
        until #t:clients() > 0 or t.index == original_t_index

        t:view_only()
    end
end

local myviewprev = function(screen)
    local t = awful.screen.focused().selected_tags[1]
    local original_t_index = t.index

    if t ~= nil then
        repeat
            t = awful.screen.focused().tags[(t.index - 2) % 9 + 1]
        until #t:clients() > 0 or t.index == original_t_index

        t:view_only()
    end
end

local move_client_to_next_tag = function()
    local c = client.focus
    local t = c and c.first_tag or nil
    if t == nil then return end

    local tag = c.screen.tags[(t.index % 9) + 1]
    c:move_to_tag(tag)
    tag:view_only()
end

local move_client_to_prev_tag = function()
    local c = client.focus
    local t = c and c.first_tag or nil
    if t == nil then return end

    local tag = c.screen.tags[(t.index - 2) % 9 + 1]
    c:move_to_tag(tag)
    tag:view_only()
end

local useless_gap_decrease = function()
    local selected_tag = awful.screen.focused().selected_tag

    if selected_tag.gap > 2 then
        selected_tag.gap = selected_tag.gap - 2
        awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
    end
end

local useless_gap_increase = function()
    local selected_tag = awful.screen.focused().selected_tag

    selected_tag.gap = selected_tag.gap + 2
    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
end

local mymaximize = function (c)
            -- Toggle titlebar
            if c.maximized then
                if not my_minimal_mode.is_enabled then awful.titlebar.show(c) end
            else
                awful.titlebar.hide(c)
            end

            -- Toggle maximize
            c.maximized = not c.maximized

            c:raise()
        end

local chrome_app_string = function(address)
    return "google-chrome-stable -app=" .. address
end

local first_empty_tag = function()
    local t = awful.screen.focused().tags[1]

    if t ~= nil then
        repeat
            t = awful.screen.focused().tags[(t.index % 9) + 1]
        until #t:clients() == 0 or t.index == 1

        t:view_only()
    end
end

local show_volume_notification = function()
    local command = "sleep 0.2 ; pacmd list-sinks | grep -zo --color=never '* index:.*base volume' |  grep -oaE '[0-9]+\\%' | head -n 1 | cut -c -3"
    awful.spawn.easy_async_with_shell(command, function(out) naughty.notify({ text = "Volume: " .. out, timeout = 1, replaces_id = -1}) end)
end

local show_backlight_notification = function()
    local command = "sleep 0.009 ; xbacklight -get | awk '{printf \"%.0f\", $0}'"
    awful.spawn.easy_async_with_shell(command, function(out) naughty.notify({ text = "Brightness: " .. out, timeout = 1, replaces_id = -1}) end)
end

local function print_awesome_memory_stats(message)
    print(os.date(), "\nLua memory usage:", collectgarbage("count"))
    local out_string = tostring(os.date()) .. "\nLua memory usage:"..tostring(collectgarbage("count")).."\n"
    out_string = out_string .. "Objects alive:"
    print("Objects alive:")
    for name, obj in pairs{ button = button, client = client, drawable = drawable, drawin = drawin, key = key, screen = screen, tag = tag } do
        out_string = out_string .. "\n" .. tostring(name) .. " = " ..tostring(obj.instances())
        print(name, obj.instances())
    end
    naughty.notify({title = "Awesome WM memory statistics " .. message, text = out_string, timeout=20, hover_timeout=20, replaces_id = -1})
end

local function launch_rofi_combi()
    awful.spawn.with_shell("rofi -show combi -combi-modi 'drun,window,run' -modi combi") -- NOTE: removed ssh
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")

-- Bling
-- TODO: https://blingcorp.github.io/bling/#/widgets/tag_preview
local bling = require("bling")
-- bling.module.flash_focus.enable()

bling.widget.window_switcher.enable {
    type = "thumbnail", -- set to anything other than "thumbnail" to disable client previews

    hide_window_switcher_key = "Escape", -- The key on which to close the popup
    minimize_key = "n",     -- The key on which to minimize the selected client
    unminimize_key = "N",   -- The key on which to unminimize all clients
    kill_client_key = "q",  -- The key on which to close the selected client
    cycle_key = "Tab",      -- The key on which to cycle through all clients
    previous_key = "Left",  -- The key on which to select the previous client
    next_key = "Right",     -- The key on which to select the next client
    vim_previous_key = "h", -- Alternative key on which to select the previous client
    vim_next_key = "l",     -- Alternative key on which to select the next client
}

qutebrowser_with_flags = "qutebrowser --qt-flag ignore-gpu-blocklist --qt-flag enable-gpu-rasterization"

terminal = "kitty"
terminal_with_tmux = terminal .. " -e /usr/bin/env tmux"

-- Use Bash for all of shell calls
awful.util.shell = "bash"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
modkey_alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- bling.layout.deck,
    bling.layout.centered,
    bling.layout.vertical,
    bling.layout.horizontal,
    bling.layout.equalarea,
    bling.layout.mstab,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "edit rc.lua", "emacs " .. awesome.conffile },
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({
    items = {
            { "Next", function() awful.tag.viewnext() end },
            { "Previous", function() awful.tag.viewprev() end },
            { "First empty tag", first_empty_tag },
        -- Essentials
            wibox.widget {widget = wibox.widget.separator},
            { "Qutebrowser", qutebrowser_with_flags },
            { "Emacs", "emacs" },
            { "Terminal (with tmux)", terminal_with_tmux },
            { "Terminal", terminal },
        -- Accessories
            wibox.widget {widget = wibox.widget.separator},
            { "Markets", "flatpak run com.bitstower.Markets" },
            { "Firefox Developer Edition", "firefox-developer-edition" },
            { "Google Chrome", "google-chrome-stable" },
            { "Chromium", "chromium" },
            { "Tranmission GTK", "transmission-gtk" },
            { "Baobab", "baobab" },
            { "Volume Pavucontrol", "pavucontrol" },
--            { "arandr", "arandr" },
        -- Music
            wibox.widget {widget = wibox.widget.separator},
            { "Spotify", "flatpak run com.spotify.Client" },
            { "Blanket", "blanket" },
        -- Chat
            wibox.widget {widget = wibox.widget.separator},
            { "Messenger/Caprine", "flatpak run com.sindresorhus.Caprine"},
            { "Discord", "flatpak run com.discordapp.Discord"},
            { "Instagram", chrome_app_string("https://instagram.com/") },
            { "Badoo", chrome_app_string("https://badoo.com/") },
            { "Bumble", chrome_app_string("https://bumble.com/app") },
            { "Tinder", chrome_app_string("https://tinder.com/") },
            { "Slack", chrome_app_string("https://app.slack.com/client/") },
            { "WhatsApp", chrome_app_string("https://web.whatsapp.com/") },
--          { "Signal", "flatopak run org.signal.Signal" },
        -- Folders
            wibox.widget {widget = wibox.widget.separator},
            { "Thunar", "thunar" },
            { "~/Downloads", "thunar Downloads" },
            { "~/D/p/elixir", "thunar Downloads/programming/elixir" },
            { "~/Documents", "thunar Documents" },
            { "~/Dropbox_encrypted", "thunar Dropbox_encrypted" },
            { "~/Videos", "thunar Videos" },
            { "~/work", "thunar work" },
        -- Printing
            wibox.widget {widget = wibox.widget.separator},
            { "Simple Scan", "simple-scan" },
            { "Print Settings", "system-config-printer" }, -- https://blog.christophersmart.com/2014/01/06/policykit-javascript-rules-with-catchall/
        -- System
            wibox.widget {widget = wibox.widget.separator},
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            wibox.widget {widget = wibox.widget.separator},
            {'lock', 'i3lock -i /opt/i3lock.png'},
            {'suspend', 'sudo zzz'},
            {'reboot', 'sudo reboot'},
            {'poweroff', 'sudo poweroff'}
}})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
vanhour = wibox.widget.textclock('<span color="#888888">(%H:%M)</span> ' , 5, "America/Vancouver")
mytextclock = wibox.widget.textclock(' <span color="#888888">%d/%m</span> <span color="#ffffff">%H:%M</span> <span color="#888888">%a</span> ' , 5)

calendar({position = "bottom_right"}):attach(vanhour)
calendar({position = "bottom_right"}):attach(mytextclock)

view_prev_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/icons/arrow-single-back.png", os.getenv("HOME"))})
view_prev_tag_button:connect_signal("button::press", function() awful.tag.viewprev(awful.screen.focused()) end)

view_next_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/icons/arrow-single-forward.png", os.getenv("HOME"))})
view_next_tag_button:connect_signal("button::press", function() awful.tag.viewnext(awful.screen.focused()) end)

move_client_to_prev_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/icons/arrow-back.png", os.getenv("HOME"))})
move_client_to_prev_tag_button:connect_signal("button::press", move_client_to_prev_tag)

move_client_to_next_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/icons/arrow-forward.png", os.getenv("HOME"))})
move_client_to_next_tag_button:connect_signal("button::press", move_client_to_next_tag)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  local t = c.first_tag
                                                  if t ~= awful.screen.focused().selected_tag then
                                                      t:view_only()
                                                  end

                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 2, function (c) c:kill() end), -- kill on middleclick
                     awful.button({ }, 3, mymaximize),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s, opacity = 0.3 })
    s.mywibox:connect_signal("mouse::enter", function() s.mywibox.opacity = 0.9 end)
    s.mywibox:connect_signal("mouse::leave", function() s.mywibox.opacity = 0.3 end)

    local spacer = function () return wibox.widget{markup = ' ', widget = wibox.widget.textbox} end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            spacer(),
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spotify_widget({font = "Iosevka Term SS09 10", show_tooltip = false}),
            spacer(),
            wibox.widget.systray(),
            spacer(),
            awful.widget.watch("available_root_space.sh", 10), -- df / -h --output=avail | tail -n 1 | tr -d " "
            spacer(),
            battery_widget({show_current_level = true, font = beautiful.font, margin_right = 10, notification_position = "bottom_right"}),
            --wibox.widget{markup = ' / ', widget = wibox.widget.textbox},
            move_client_to_prev_tag_button,
            move_client_to_next_tag_button,
            spacer(),
            view_prev_tag_button,
            view_next_tag_button,
            mytextclock,
            vanhour,
            s.mylayoutbox,
            my_minimal_mode.widget
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({modkey}, 1, first_empty_tag),
    awful.button({ }, 1, function ()
      local mouse_x = mouse.coords().x
      local middle_x = mouse.screen.geometry.x + (mouse.screen.geometry.width / 2)

      if mouse_x < middle_x then myviewprev() else myviewnext() end
    end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, function () useless_gap_decrease() end),
    awful.button({ }, 5, useless_gap_increase)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, modkey_alt}, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "h",   myviewprev,
              {description = "my view previous tag", group = "tag"}),
    awful.key({ modkey,           }, "l",  myviewnext,
              {description = "my view next tag", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "Escape",   myviewprev,
              {description = "my view previous tag (Super+Shift+Esc)", group = "tag"}),
    awful.key({ modkey,           }, "Escape",  myviewnext,
              {description = "my view next tag (Super+Esc))", group = "tag"}),

    awful.key({ modkey, "Control" }, "h",   awful.tag.viewprev,
              {description = "view previous tag", group = "tag"}),
    awful.key({ modkey, "Control" }, "l",  awful.tag.viewnext,
              {description = "view next tag", group = "tag"}),

    awful.key({ modkey,       }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "j", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey }, "o", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "o",      function ()
            local t = awful.screen.focused().selected_tag

            for _, c in ipairs(t:clients()) do
                c:move_to_screen()
            end
    end, {description = "move all clients to screen", group = "client"}),
    awful.key({ modkey, }, ",", function () awful.screen.focus_relative(1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey }, ".", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    awful.key({ modkey, }, "F1", function () awful.screen.focus(1) end,
              {description = "focus screen 1", group = "screen"}),
    awful.key({ modkey }, "F2", function () awful.screen.focus(2) end,
              {description = "focus screen 2", group = "screen"}),
    awful.key({ modkey }, "F3", function () awful.screen.focus(3) end,
              {description = "focus screen 3", group = "screen"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, ";", toggle_useless_gaps_and_mfpol,
              {description = "toggle useless gaps in current tag", group = "client"}),
    awful.key({ modkey, "Shift"   }, ";", remove_useless_gaps,
              {description = "remove useless gaps in current tag", group = "client"}),
    awful.key({ modkey,           }, "'", toggle_even_split,
              {description = "toggle even split in current tag", group = "client"}),
    awful.key({ modkey,           }, "y", awful.tag.togglemfpol,
              {description = "toggle master size fill policy", group = "client"}),
    awful.key({ modkey_alt,           }, "Tab", function ()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end),

    -- AwesomeWM restart and print stats
    awful.key({ modkey, "Shift" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),

    awful.key({modkey,"Control" }, "r", function()
            print_awesome_memory_stats("Precollect")
            collectgarbage("collect")
            collectgarbage("collect")
            gears.timer.start_new(5, function()
                                      print_awesome_memory_stats("Postcollect")
                                      return false
            end)
    end, {description = "print awesome wm memory statistics", group="awesome"}),

    -- Resize tag's master_width_factor
    awful.key({ modkey,           }, "[",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "]",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),

    -- Resize client's master_width_factor
    awful.key({ modkey, modkey_alt    }, "[", function () awful.client.incwfact(-0.15)    end,
              {description = "decrease client's master width factor", group = "client"}),
    awful.key({ modkey, modkey_alt    }, "]", function () awful.client.incwfact( 0.15)    end,
              {description = "increase client's master width factor", group = "client"}),


    -- Increase/Decrease master clients or master columns
    awful.key({ modkey, "Control"}, "[",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control"}, "]",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift" }, "[",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift" }, "]",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    -- Layouts
    awful.key({ modkey_alt,           }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey_alt, "Shift"   }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Shift" }, "m", my_minimal_mode.toggle, {description = "toggle minimal mode", group = "layout"}),

    awful.key({ modkey, "Shift" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then c:emit_signal("request::activate", "key.unminimize", {raise = true}) end
        end,
        {description = "restore minimized", group = "client"}),

    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end, {description = "lua execute prompt", group = "awesome"}),


    -- First empty tag
    awful.key({ modkey, "Control" }, "Return", first_empty_tag, {description = "find first empty tag", group = "launcher"}),

    -- Useless gap increase/decrease
    awful.key({modkey, "Shift"}, "=", useless_gap_decrease, {description = "Decrease useless gap", group = "layout"}),
    awful.key({modkey, "Shift"}, "-", useless_gap_increase, {description = "Increase useless gap", group = "layout"}),

    -- My apps / shortcuts
    awful.key({ modkey }, "w", function () awful.spawn(qutebrowser_with_flags) end,
              {description = "open qutebrowser", group = "launcher"}),
    awful.key({ modkey, "Shift"}, "w", function () awful.spawn("google-chrome-stable") end,
              {description = "open google-chrome-stable", group = "launcher"}),
    awful.key({ modkey, "Control"}, "w", function () awful.spawn("firefox-developer-edition") end,
              {description = "open firefox-developer-edition", group = "launcher"}),
    awful.key({ modkey }, "e", function () awful.spawn("emacs") end,
              {description = "open emacs", group = "launcher"}),
    awful.key({ modkey, "Shift"}, "e", function () awful.spawn(terminal .. " -e nvim") end,
              {description = "open nvim in default teraminal", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.spawn(terminal .. " -e ranger") end,
        {description = "open ranger", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "f", function () awful.spawn("thunar") end,
              {description = "thunar", group = "launcher"}),
    awful.key({ modkey }, "z", function () awful.spawn("flatpak run com.spotify.Client") end,
              {description = "open spotify (flatpak version)", group = "launcher"}),
    awful.key({ modkey, }, "c", function () awful.spawn("flatpak run com.sindresorhus.Caprine") end,
        {description = "open messenger/caprine", group = "launcher"}),
    awful.key({ modkey }, "r", function () awful.spawn.with_shell("toggle_redshift") end,
              {description = "toggle redshift", group = "launcher"}),

    -- system
    awful.key({ modkey, "Shift" }, "s", function () awful.spawn.with_shell("sudo zzz") end,
              {description = "Suspend", group = "system"}),
    awful.key({ modkey, "Control" }, "s", function () awful.spawn.with_shell("i3lock -i /opt/i3lock.png") end,
              {description = "Lock", group = "system"}),
    awful.key({ modkey, }, "a", function () awful.spawn.with_shell("arandr") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "a", function () awful.spawn("autorandr -c --default laptop") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, }, "v", function () awful.spawn("pavucontrol") end,
              {description = "pavucontrol", group = "launcher"}),

   -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()
           awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
           show_volume_notification()
   end),
   awful.key({}, "XF86AudioRaiseVolume", function ()
           awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
           show_volume_notification()
   end),
   awful.key({}, "XF86AudioMute", function ()
           awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle", false)
           show_volume_notification()
   end),

   awful.key({modkey_alt, modkey }, "-", function ()
           awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%", false)
           show_volume_notification()
   end),
   awful.key({modkey_alt, modkey }, "=", function ()
           awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
           show_volume_notification()
   end),

   awful.key({modkey}, "d", function ()
           awful.spawn.with_shell("xdotool click --repeat 5 --delay 0 5") -- emulate scroll down
   end),

   -- this does not work for some reason
   awful.key({modkey, "Shift"}, "d", function ()
           awful.spawn.with_shell("xdotool click --repeat 5 --delay 0 4") -- emulate scroll up
   end),

   -- Media Keys
   awful.key({}, "XF86AudioPlay", function()
     awful.spawn.with_shell("playerctl play-pause", false)
   end),
   awful.key({}, "XF86AudioNext", function()
     awful.spawn.with_shell("playerctl next", false)
   end),
   awful.key({}, "XF86AudioPrev", function()
     awful.spawn.with_shell("playerctl previous", false)
   end),

   -- Brightness
   awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn.with_shell("xbacklight -dec 15"); show_backlight_notification() end),
   awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn.with_shell("xbacklight -inc 15"); show_backlight_notification() end),
   awful.key({modkey, "Control" }, "-", function () awful.spawn.easy_async_with_shell("xbacklight -set 1", function() show_backlight_notification() end) end),
   awful.key({modkey, "Control" }, "=", function () awful.spawn.easy_async_with_shell("xbacklight -set 100", function() show_backlight_notification() end) end),

   -- Screenshots
   awful.key({ }, "Print", function () awful.spawn.with_shell('import -window root ~/Pictures/`date +"%F-%H:%M.%N"`.png') end,
     {description = "Take a screenshot of entire screen", group = "screenshot"}),
   awful.key({ modkey, "Shift" }, "Print", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),
   awful.key({ modkey, }, "Print", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),

   awful.key({ modkey }, "BackSpace", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),

    -- Rofi combi
    awful.key({ modkey, "Shift" }, "Return", launch_rofi_combi, {description = "show rofi combi with enter", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "space", launch_rofi_combi, {description = "show rofi combi with space", group = "launcher"}),

    -- Rofi calc
    -- install this: https://github.com/svenstaro/rofi-calc
    awful.key({ modkey,           }, "space", function () awful.spawn("rofi -show calc -modi calc -no-show-match -no-sort -lines 1 -calc-command \"echo -n '{result}' | xclip -selection clipboard\"")                end,
              {description = "show rofi calc/converter", group = "launcher"}),

    awful.key({ modkey, }, "`", function () awful.spawn.with_shell("rofi -show window") end,
    {description = "show rofi window", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "\\", function () awful.spawn.with_shell("rofi -show ssh") end,
    {description = "show rofi ssh", group = "launcher"}),

    -- Rofi bluetooth -- https://github.com/nickclyde/rofi-bluetooth
    awful.key({ modkey, "Control" }, "b", function () awful.spawn.with_shell("rofi-bluetooth") end,
    {description = "show rofi ssh", group = "launcher"}),

    -- terminal
    awful.key({ modkey, }, "Return", function () awful.spawn(terminal_with_tmux) end,
        {description = "open a terminal (with tmux)", group = "launcher"}),
    -- awful.key({ modkey, }, "t", function () awful.spawn(terminal_with_tmux) end,
    --     {description = "open a terminal (with tmux)", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "t", function () awful.spawn(terminal) end,
        {description = "open a terminal (without tmux)", group = "launcher"}),
    awful.key({ modkey, }, "g", function () awful.spawn(terminal .. " -e glances") end,
        {description = "open glances", group = "launcher"}),

    -- Toggler Wibox
     awful.key({ modkey, "Shift" }, "b", function ()
             s = mouse.screen

             s.mywibox.visible = not s.mywibox.visible
             if s.mybottomwibox then
                 s.mybottomwibox.visible = not s.mybottomwibox.visible
             end
     end, {description = "toggle wibox", group = "awesome"}),

    -- Super+Shift+h/l: move client to prev/next tag
    awful.key({ modkey, "Shift" }, "h", move_client_to_prev_tag, {description = "move client to previous tag", group = "layout"}),
    awful.key({ modkey, "Shift" }, "l", move_client_to_next_tag, {description = "move client to next tag", group = "layout"}),

    -- my_tag_expander
    awful.key({ modkey }, "q", my_tag_expander.from_left, {description = "expand selected tags from left", group = "layout"}),
    awful.key({ modkey, "Shift"}, "q", my_tag_expander.from_right, {description = "expand selected tags from right", group = "layout"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "i",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift" }, "p", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey, }, "p",  function() client.focus = awful.client.getmaster(); client.focus:raise() end,
              {description = "focus master", group = "client"}),
    awful.key({ modkey, "Shift" }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift" },  ".",      function (c) c:move_to_screen (c.screen.index-1)               end,
              {description = "move to previous screen", group = "client"}),
    awful.key({ modkey, "Shift" },  ",",      function (c) c:move_to_screen (c.screen.index+1)               end,
              {description = "move to next screen", group = "client"}),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky            end,
              {description = "toggle sticky", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "b", function(c) awful.titlebar.toggle(c) end, {description = 'toggle title bar', group = 'client'}), -- Toggle titlebars

    -- Opacity changes
    awful.key({modkey}, "-", function(c) c.opacity = c.opacity - 0.02 end, {description = "Decrease opacity", group = "layout"}),
    awful.key({modkey}, "=", function(c) c.opacity = c.opacity + 0.02 end, {description = "Increase opacity", group = "layout"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m", mymaximize , {description = "(un)maximize", group = "client"}),
    awful.key({ modkey,  }, "Up", function(c) c.opacity = 1 end, {description = "full opacity", group = "client"}),
    awful.key({ modkey,  }, "Down", function(c) c.opacity = 0.2 end, {description = "dim opacity", group = "client"}),
    awful.key({ modkey,  }, "Left", function(c) c.opacity = c.opacity - 0.1 end, {description = "decrease opacity", group = "client"}),
    awful.key({ modkey,  }, "Right", function(c) c.opacity = c.opacity + 0.1 end, {description = "increase opacity", group = "client"}),

    -- Toggle to floating and align to window edges
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, {description = "toggle floating", group = "client"}),
    awful.key({ modkey, modkey_alt }, "space",  awful.client.floating.toggle, {description = "toggle floating", group = "client"}),
    awful.key({ modkey, modkey_alt }, "h", function(c)
        c.floating = true;
        local axis = 'vertically'
        local f = awful.placement.scale
            + awful.placement.left
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5, margins = 2})
    end),
    awful.key({ modkey, modkey_alt }, "j", function(c)
        c.floating = true;
        local axis = 'horizontally'
        local f = awful.placement.scale
            + awful.placement.bottom
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5, margins = 2})
    end),
    awful.key({ modkey, modkey_alt }, "k", function(c)
        c.floating = true;
        local axis = 'horizontally'
        local f = awful.placement.scale
            + awful.placement.top
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5, margins = 2})
    end),
    awful.key({ modkey, modkey_alt }, "l", function(c)
        c.floating = true;
        local axis = 'vertically'
        local f = awful.placement.scale
            + awful.placement.right
            + (axis and awful.placement['maximize_'..axis] or nil)
        f(client.focus, {honor_workarea=true, to_percent = 0.5, margins = 2})
    end),

    awful.key({ modkey, "Control"}, "j", function (c)
            awful.client.swap.byidx("1", c)
            client.focus = awful.client.next(-1, c)
            client.focus:raise()
    end, {description = "swap client down and change focus", group = "client"}),
    awful.key({ modkey, "Control"}, "k", function (c)
            awful.client.swap.byidx("-1", c)
            client.focus = awful.client.next(1, c)
            client.focus:raise()
    end, {description = "swap client up and change focus", group = "client"}),
    awful.key({ modkey, "Control"}, "p",  function(c)
            local prev_master = awful.client.getmaster()

            c:swap(prev_master)
            client.focus = prev_master
            client.focus:raise()
    end, {description = "swap with master and change focus", group = "client"}),

    awful.key({ modkey, "Shift" }, "Tab", function (c)
            awful.tag.history.restore()
            c:move_to_tag(awful.screen.focused().selected_tag)
            awful.tag.history.restore()
    end, {description = "move client to previously selected tag", group = "client"})
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                         local clients = tag:clients()

                         for i, c in pairs(clients) do
                             if c:isvisible() then
                                 client.focus = c
                             end
                         end
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, modkey_alt }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
    awful.button({ modkey }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
    awful.button({ modkey }, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c) end),
    -- awful.button({ modkey }, 4, function(c) c.opacity = c.opacity + 0.02 end),
    -- awful.button({ modkey }, 5, function(c) c.opacity = c.opacity - 0.02 end),
    awful.button({ modkey }, 8, function(c)
         local t = c.first_tag
         local tag = c.screen.tags[(t.index % 9) + 1]
         c:move_to_tag(tag)
         tag:view_only()
    end),
    awful.button({ modkey }, 9, function(c)
         local t = c.first_tag
         local tag = c.screen.tags[(t.index - 2) % 9 + 1]
         c:move_to_tag(tag)
         tag:view_only()
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          -- "Arandr",
          -- "Blueman-manager"
          },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
          -- "Volume Control",
          "KMagnifier"
        },
        role = {
          -- "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- No borders for conky and ulauncher
    { rule_any = {instance = {"conky", "ulauncher"}}, properties = { border_width = 0, titlebars_enabled = false }},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = theme.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = theme.border_normal end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    local function mymaximizedbutton(c)
        local widget = awful.titlebar.widget.button(c, "maximized",
                                              function(cl) return cl.maximized end,
                                              function(cl, state) mymaximize(cl) end
        )
      c:connect_signal("property::maximized", widget.update)
      return widget
    end

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            -- awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                -- widget = awful.titlebar.widget.titlewidget(c)
                widget = wibox.widget{markup = '', widget = wibox.widget.textbox},
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.button (c, "move_to_prev_tag", function () return awful.util.get_configuration_dir() .. "/icons/arrow-back.png" end, function ()
                                              local t = c.first_tag
                                              local tag = c.screen.tags[(t.index - 2) % 9 + 1]
                                              c:move_to_tag(tag)
                                              -- tag:view_only()
                                              end),
            awful.titlebar.widget.button (c, "move_to_next_tag", function () return awful.util.get_configuration_dir() .. "/icons/arrow-forward.png" end, function ()
                                              local t = c.first_tag
                                              local tag = c.screen.tags[(t.index % 9) + 1]
                                              c:move_to_tag(tag)
                                              -- tag:view_only()
                                              end),
            wibox.widget{markup = ' ', widget = wibox.widget.textbox},
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            mymaximizedbutton(c),
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

    if c.maximized or my_minimal_mode.is_enabled then awful.titlebar.hide(c); end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
                          local only_one = #s.tiled_clients == 1
                          for _, c in pairs(s.clients) do
                              if only_one and not c.floating or c.maximized then
                                  c.border_width = 0
                              else
                                  if c.instance ~= "conky" then
                                      c.border_width = beautiful.border_width
                                  end
                              end
                          end
end)

awful.screen.connect_for_each_screen(function(s)
        if screen:count() == 1 then
            gears.wallpaper.set("#161616")
            return
        end

        if s.geometry.width <= 1920 then
            -- Don't add desktop buttons if on laptop
            gears.wallpaper.fit(string.format("%s/.config/awesome/wallpapers/homerow.png", os.getenv("HOME")), s)
        else
            gears.wallpaper.fit(string.format("%s/.config/awesome/wallpapers/traveller.png", os.getenv("HOME")), s)
            my_top_bar.attach_to_screen(s)
        end;

        s.tags[1].master_fill_policy = "expand"
        -- s.tags[1].gap = 2
end)

local current_tag = awful.screen.focused().selected_tag
if current_tag.index == 1 then
   current_tag.master_fill_policy = "expand"
   current_tag.gap = 2
end

-- Autorun/autostart programs
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
