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
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- awesome-wm-widgets
local docker_widget = require("awesome-wm-widgets.docker-widget.docker")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")

-- calendar from https://github.com/deficient/calendar
local calendar = require("calendar")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Useful variables to reuse
local screenshot_bash_date_path = '/home/b/Pictures/`date +"%F-%H:%M.%N"`.png'

-- Extract useless gap increase per tag
local useless_gap_decrease = function()
    if beautiful.useless_gap > 0 then
        beautiful.useless_gap = beautiful.useless_gap - 2
        awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
    end
end

local useless_gap_increase = function()
    beautiful.useless_gap = beautiful.useless_gap + 2
    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
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
beautiful.init("/home/b/.config/awesome/theme.lua")

terminal = "alacritty"
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
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", "emacs " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "terminal", terminal }
local menu_system = { "system", {
                          {'slock', 'slock'},
                          {'suspend', 'slock systemctl suspend'},
                          {'reboot', 'sudo reboot'},
                          {'poweroff', 'sudo poweroff'}
    }
}

if has_fdo then
    mymainmenu = freedesktop.menu.build({
            before = {
                menu_terminal,
                {"Google Chrome", "google-chrome" },
                {"Signal (disabled GPU)", "signal-desktop --disable-gpu" },
                {"Messenger", "google-chrome --app=https://messenger.com/" },
                {"Thunar", "thunar" },
                {"open spotify in google chrome", "google-chrome --app=https://open.spotify.com/" },
            },
            after =  {
                menu_awesome,
                menu_system,
            }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = awful.widget.textclock(
    '<span color="#aaaaaa">%A %d/%m/%Y</span> <span color="#ffffff">%H:%M</span> <span color="#333333">|</span> '
, 5)

calendar({}):attach(mytextclock)

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
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

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
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            wibox.widget{markup = ' / ', widget = wibox.widget.textbox},
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mytextclock,
            wibox.widget.systray(),
            docker_widget(),
            s.mylayoutbox,
            logout_menu_widget({
                    onlogout = function() awesome.quit() end,
                    onlock = function() awful.spawn.with_shell('slock') end,
                    onsuspend = function() awful.spawn.with_shell("slock systemctl suspend") end,
                    onreboot = function() awful.spawn.with_shell("sudo reboot") end,
                    onpoweroff = function() awful.spawn.with_shell("sudo poweroff") end,
            })
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, function ()
            if awful.screen.focused().selected_tag.gap > 2 then
                useless_gap_decrease()
            end
    end),
    awful.button({ }, 5, useless_gap_increase)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
    --           {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "h",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "l",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,       }, "Tab", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey }, "o", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey }, ",", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, }, ".", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey_alt,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey,           }, "[",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, "]",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Control"}, "[",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control"}, "]",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift" }, "[",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift" }, "]",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey_alt,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey_alt, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Shift" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", {raise = true}
                )
            end
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
        end,
        {description = "lua execute prompt", group = "awesome"}),


    -- Menubar
    awful.key({ modkey, "Control" }, "Return", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Useless gap increase/decrease
    awful.key({modkey, "Shift"}, "=", useless_gap_decrease, {description = "Decrease useless gap", group = "layout"}),
    awful.key({modkey, "Shift"}, "-", useless_gap_increase, {description = "Increase useless gap", group = "layout"}),

    -- My apps / shortcuts
    awful.key({ modkey }, "w", function () awful.spawn("google-chrome") end,
              {description = "open google chrome", group = "launcher"}),
    awful.key({ modkey, "Shift"}, "w", function () awful.spawn("brave-browser") end,
              {description = "open brave browser", group = "launcher"}),
    awful.key({ modkey}, "q", function () awful.spawn("qutebrowser") end,
              {description = "open qutebrowser", group = "launcher"}),
    awful.key({ modkey, "Shift"}, "q", function () awful.spawn("qutebrowser --target window ~/Pictures/cheatsheet-qutebrowser.png") end,
              {description = "open qutebrowser help", group = "launcher"}),
    awful.key({ modkey }, "e", function () awful.spawn("emacs") end,
              {description = "emacs", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.spawn(terminal .. " -e ranger") end,
        {description = "open ranger", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "f", function () awful.spawn("thunar") end,
              {description = "thunar", group = "launcher"}),
    awful.key({ modkey }, "z", function () awful.spawn.with_shell("google-chrome --app=https://open.spotify.com/") end,
              {description = "open spotify in google chrome", group = "launcher"}),
    awful.key({ modkey, }, "c", function () awful.spawn("google-chrome --app=https://messenger.com/") end,
        {description = "open messenger in google chrome", group = "launcher"}),
    awful.key({ modkey }, "r", function () awful.spawn.with_shell("toggle_redshift") end,
              {description = "toggle redshift", group = "launcher"}),

    -- system
    awful.key({ modkey, "Shift" }, "s", function () awful.spawn.with_shell("slock systemctl suspend") end,
              {description = "LOCK AND SUSPEND", group = "system"}),
    awful.key({ modkey, "Control" }, "s", function () awful.spawn.with_shell("slock") end,
              {description = "LOCK", group = "system"}),
    awful.key({ modkey, }, "a", function () awful.spawn.with_shell("arandr") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "a", function () awful.spawn("lxrandr") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, }, "v", function () awful.spawn("pavucontrol-qt") end,
              {description = "pavucontrol-qt", group = "launcher"}),

   -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()
     awful.spawn.with_shell("amixer -q -D pulse sset Master 5%-", false)
   end),
   awful.key({}, "XF86AudioRaiseVolume", function ()
     awful.spawn.with_shell("amixer -q -D pulse sset Master 5%+", false)
   end),
   awful.key({}, "XF86AudioMute", function ()
     awful.spawn.with_shell("amixer -D pulse set Master 1+ toggle", false)
   end),

   awful.key({modkey_alt, "Control" }, "-", function ()
     awful.spawn.with_shell("amixer -q -D pulse sset Master 5%-", false)
   end),
   awful.key({modkey_alt, "Control" }, "=", function ()
     awful.spawn.with_shell("amixer -q -D pulse sset Master 5%+", false)
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
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.spawn.with_shell("xbacklight -dec 15") end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.spawn.with_shell("xbacklight -inc 15") end),
    awful.key({modkey, "Control" }, "-", function ()
        awful.spawn.with_shell("xbacklight -set 1") end),
    awful.key({modkey, "Control" }, "=", function ()
        awful.spawn.with_shell("xbacklight -set 100") end),

   -- Screenshots
   awful.key({ }, "Print", function () awful.spawn.with_shell('import -window root ' .. screenshot_bash_date_path) end,
     {description = "Take a screenshot of entire screen", group = "screenshot"}),
   awful.key({ modkey, "Shift" }, "Print", function () awful.spawn.with_shell('import ' .. screenshot_bash_date_path) end,
     {description = "Take a screenshot of selection", group = "screenshot"}),
   awful.key({ modkey }, "Print", function () awful.spawn.with_shell('import -descend ' .. screenshot_bash_date_path) end,
     {description = "Take a screenshot of clicked window", group = "screenshot"}),
   awful.key({ modkey }, "BackSpace", function () awful.spawn.with_shell('import ' .. screenshot_bash_date_path) end,
     {description = "Take a screenshot of selection", group = "screenshot"}),

    -- rofi
    awful.key({ modkey, "Shift" }, "Return", function () awful.spawn.with_shell("rofi -show drun") end,
    {description = "show rofi run", group = "launcher"}),

    awful.key({ modkey, }, "`", function () awful.spawn.with_shell("rofi -show window") end,
    {description = "show rofi window", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "\\", function () awful.spawn.with_shell("rofi -show ssh") end,
    {description = "show rofi ssh", group = "launcher"}),

    -- terminal
    awful.key({ modkey, }, "Return", function () awful.spawn(terminal_with_tmux) end,
        {description = "open a terminal", group = "launcher"}),
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
awful.key({ modkey, "Shift" }, "h",
    function ()
        -- get current tag
        local t = client.focus and client.focus.first_tag or nil
        if t == nil then
            return
        end
        -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
        local tag = client.focus.screen.tags[(t.index - 2) % 9 + 1]
        awful.client.movetotag(tag)
        tag:view_only()
    end,
        {description = "move client to previous tag", group = "layout"}),
awful.key({ modkey, "Shift" }, "l",
    function ()
        -- get current tag
        local t = client.focus and client.focus.first_tag or nil
        if t == nil then
            return
        end
        -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
        local tag = client.focus.screen.tags[(t.index % 9) + 1]
        awful.client.movetotag(tag)
        tag:view_only()
    end,
        {description = "move client to next tag", group = "layout"})
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
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Shift" }, "p", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey, }, "p",  function() client.focus = awful.client.getmaster(); client.focus:raise() end,
              {description = "focus master", group = "client"}),
    awful.key({ modkey, "Shift" }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift" },  ",",      function (c) c:move_to_screen (c.screen.index-1)               end,
              {description = "move to previous screen", group = "client"}),
    awful.key({ modkey, "Shift" },  ".",      function (c) c:move_to_screen (c.screen.index+1)               end,
              {description = "move to next screen", group = "client"}),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky            end,
              {description = "toggle sticky", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, 'b', function(c) awful.titlebar.toggle(c) end, {description = 'toggle title bar', group = 'client'}), -- Toggle titlebars

    -- Opacity changes
    awful.key({modkey}, "-", function(c) c.opacity = c.opacity - 0.1 end, {description = "Decrease opacity", group = "layout"}),
    awful.key({modkey}, "=", function(c) c.opacity = c.opacity + 0.1 end, {description = "Increase opacity", group = "layout"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey,  }, "Up", function(c) c.opacity = 1 end, {description = "full opacity", group = "client"}),
    awful.key({ modkey,  }, "Down", function(c) c.opacity = 0.2 end, {description = "dim opacity", group = "client"}),
    awful.key({ modkey,  }, "Left", function(c) c.opacity = c.opacity - 0.1 end, {description = "decrease opacity", group = "client"}),
    awful.key({ modkey,  }, "Right", function(c) c.opacity = c.opacity + 0.1 end, {description = "increase opacity", group = "client"})
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
        awful.key({ modkey_alt, "Shift" }, "#" .. i + 9,
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
                awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
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
    awful.button({ modkey }, 4, function(c) c.opacity = c.opacity + 0.1 end),
    awful.button({ modkey }, 5, function(c) c.opacity = c.opacity - 0.1 end)
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
        },
        role = {
          -- "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- No borders for conky
    { rule_any = {instance = {"conky"}}, properties = { border_width = 0 }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

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
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

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

    awful.titlebar(c, {size = 20}) : setup {
        { -- Left -- awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Middle
            -- { Title align  = "center", -- widget = awful.titlebar.widget.titlewidget(c)},
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Wallpaper
-- awful.spawn.with_shell("nitrogen --restore")
gears.wallpaper.set("#202020")

-- Autorun/autostart programs
awful.spawn.with_shell("dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY")  -- gtk apps take ages to load without that
awful.spawn.with_shell("killall fusuma; ~/.rvm/gems/ruby-3.0.1/bin/fusuma")
awful.spawn.with_shell("killall ulauncher; ulauncher --no-window-shadow --hide-window")
awful.spawn.with_shell("killall conky ; conky")
awful.spawn.with_shell("killall xss-lock ; xss-lock slock") -- slock on lid close/sleep

awful.spawn.with_shell("~/.config/awesome/autostart.sh")
