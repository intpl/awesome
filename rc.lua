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
-- local docker_widget = require("awesome-wm-widgets.docker-widget.docker")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local battery_widget = require("awesome-wm-widgets.battery-widget.battery") -- icons: https://github.com/horst3180/arc-icon-theme

-- awesome buttons
local awesomebuttons = require("awesome-buttons.awesome-buttons")

-- calendar from https://github.com/deficient/calendar
local calendar = require("calendar")

-- Awesome Cyclefocus
-- local cyclefocus = require('cyclefocus')

-- My Modules
local my_minimal_mode = require('my_modules.my_minimal_mode')
local my_transparency_mode = require('my_modules.my_transparency_mode')
local hotcorner = require("my_modules.hotcorner")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Useful variables to reuse
local screenshot_bash_date_path = '~/Pictures/`date +"%F-%H:%M.%N"`.png'

local toggle_useless_gaps = function()
    local selected_tag = awful.screen.focused().selected_tag

    if selected_tag.gap ~= 2 then
        selected_tag.gap = 2
    else
        selected_tag.gap = 20
    end

    awful.screen.connect_for_each_screen(function(s) awful.layout.arrange(s) end)
end

local remove_useless_gaps = function()
    awful.screen.focused().selected_tag.gap = 0
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
    -- get current tag
    local t = client.focus and client.focus.first_tag or nil
    if t == nil then
        return
    end
    -- get next tag (modulo 9 excluding 0 to wrap from 9 to 1)
    local tag = client.focus.screen.tags[(t.index % 9) + 1]
    awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
    tag:view_only()
end

local move_client_to_prev_tag = function()
    -- get current tag
    local t = client.focus and client.focus.first_tag or nil
    if t == nil then
        return
    end
    -- get previous tag (modulo 9 excluding 0 to wrap from 1 to 9)
    local tag = client.focus.screen.tags[(t.index - 2) % 9 + 1]
    awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
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
    return "google-chrome -app=" .. address
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
    local command = "pacmd list-sinks | grep -zo --color=never '* index:.*base volume' | grep -oaE '[0-9]+\\%' | awk -v RS= '{$1= $1}1'"
    awful.spawn.easy_async_with_shell(command, function(out) naughty.notify({ text = out, timeout = 1 }) end)
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
    awful.layout.suit.spiral,
    -- bling.layout.deck,
    bling.layout.centered,
    bling.layout.vertical,
    bling.layout.horizontal,
    bling.layout.equalarea,
    bling.layout.mstab,
    -- awful.layout.suit.spiral.dwindle,
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
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "Terminal (w/o tmux)", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
            before = {
                { "Terminal (tmux)", terminal_with_tmux },
                menu_terminal,
                {"Blueman manager", "blueman-manager"},
                {"arandr", "arandr"},
                {"Slack", "slack"},
                {"Emacs", "emacs"},
                {"Google Chrome", "google-chrome" },
                {"Thunar", "thunar" },
                {"Tranmission GTK", "transmission-gtk" },
                wibox.widget {widget = wibox.widget.separator},
                {"KMagnifier", "kmag"},
                {"Blanket", "blanket" }, -- https://github.com/rafaelmardojai/blanket
                wibox.widget {widget = wibox.widget.separator},
                {"Signal", "signal-desktop --disable-gpu" },
                {"Messenger", chrome_app_string("https://messenger.com/") },
                {"Tinder", chrome_app_string("https://tinder.com/") },
                {"Instagram", chrome_app_string("https://instagram.com/") },
                {"WhatsApp", chrome_app_string("https://web.whatsapp.com/") },
                {"Spotify", chrome_app_string("https://open.spotify.com/") },
                wibox.widget {widget = wibox.widget.separator},
            },
            after =  {
                wibox.widget {widget = wibox.widget.separator},
                menu_awesome,
                { "edit rc.lua", "emacs " .. awesome.conffile },
                wibox.widget {widget = wibox.widget.separator},
                {'lock', 'light-locker-command -l'},
                {'suspend', 'sudo systemctl suspend'},
                {'reboot', 'sudo reboot'},
                {'poweroff', 'sudo poweroff'}
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
mytextclock = wibox.widget.textclock(
    ' <span color="#888888">%d/%m</span> <span color="#ffffff">%H:%M</span> <span color="#888888">%a</span> '
, 5)

calendar({position = "bottom_right"}):attach(mytextclock)

view_prev_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/arrow-single-back.png", os.getenv("HOME"))})
view_prev_tag_button:connect_signal("button::press", function() awful.tag.viewprev(awful.screen.focused()) end)

view_next_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/arrow-single-forward.png", os.getenv("HOME"))})
view_next_tag_button:connect_signal("button::press", function() awful.tag.viewnext(awful.screen.focused()) end)

move_client_to_prev_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/arrow-back.png", os.getenv("HOME"))})
move_client_to_prev_tag_button:connect_signal("button::press", move_client_to_prev_tag)

move_client_to_next_tag_button = awful.widget.button({image = string.format("%s/.config/awesome/arrow-forward.png", os.getenv("HOME"))})
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
                     awful.button({ }, 3, mymaximize), -- awful.menu.client_list({ theme = { width = 250 } })
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
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            wibox.widget{markup = ' ', widget = wibox.widget.textbox},
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            -- docker_widget(),
            battery_widget({show_current_level = true, font = beautiful.font, margin_right = 10}),
            --wibox.widget{markup = ' / ', widget = wibox.widget.textbox},
            move_client_to_prev_tag_button,
            move_client_to_next_tag_button,
            wibox.widget{markup = ' / ', widget = wibox.widget.textbox},
            view_prev_tag_button,
            view_next_tag_button,
            mytextclock,
            s.mylayoutbox,
            logout_menu_widget({
                    onlogout = function() awesome.quit() end,
                    onlock = function() awful.spawn.with_shell('light-locker-command -l') end,
                    onsuspend = function() awful.spawn.with_shell("sudo systemctl suspend") end,
                    onreboot = function() awful.spawn.with_shell("sudo reboot") end,
                    onpoweroff = function() awful.spawn.with_shell("sudo poweroff") end,
            }),
            my_transparency_mode.widget,
            my_minimal_mode.widget
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({modkey}, 1, first_empty_tag),
    awful.button({ }, 1, function ()
            if mouse.coords().x < (mouse.screen.geometry.width/2) then
                myviewprev()
            else
                myviewnext()
            end
    end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, function () useless_gap_decrease() end),
    awful.button({ }, 5, useless_gap_increase)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
    --           {description="show help", group="awesome"}),
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
    awful.key({ modkey, }, ".", function () awful.screen.focus_relative(1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey }, ",", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, ";", toggle_useless_gaps,
              {description = "toggle useless gaps in current tag", group = "client"}),
    awful.key({ modkey, "Shift"   }, ";", remove_useless_gaps,
              {description = "remove useless gaps in current tag", group = "client"}),
    awful.key({ modkey,           }, "'", toggle_even_split,
              {description = "toggle even split in current tag", group = "client"}),
    awful.key({ modkey,           }, "y", awful.tag.togglemfpol,
              {description = "toggle master size fill policy", group = "client"}),
--    cyclefocus.key({ modkey_alt, }, "Tab", {}),
    awful.key({ modkey_alt,           }, "Tab",
        function() awesome.emit_signal("bling::window_switcher::turn_on") end),

    -- Standard program
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

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


    -- Resize client's master_width_factor DEPRECATED (lol)
    awful.key({ modkey, "Control"    }, "j", function () naughty.notify({preset = naughty.config.presets.critical, text = "DEPCRECATED: use modkey-alt-[" }); awful.client.incwfact(-0.15)    end,
              {description = "decrease client's master width factor", group = "client"}),
    awful.key({ modkey, "Control"    }, "k", function () naughty.notify({preset = naughty.config.presets.critical, text = "DEPCRECATED: use modkey-alt-]" }); awful.client.incwfact( 0.15)    end,
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

    -- My modes
    awful.key({ modkey, "Shift" }, "m", my_minimal_mode.toggle, {description = "toggle minimal mode", group = "layout"}),
    awful.key({ modkey, "Shift" }, "y", my_transparency_mode.toggle, {description = "toggle transparency mode", group = "layout"}),

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
    awful.key({ modkey, "Shift" }, "s", function () awful.spawn.with_shell("sudo systemctl suspend") end,
              {description = "Suspend", group = "system"}),
    awful.key({ modkey, "Control" }, "s", function () awful.spawn.with_shell("light-locker-command -l") end,
              {description = "Lock", group = "system"}),
    awful.key({ modkey, }, "a", function () awful.spawn.with_shell("arandr") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "a", function () awful.spawn("lxrandr") end,
              {description = "arandr", group = "launcher"}),
    awful.key({ modkey, }, "v", function () awful.spawn("pavucontrol") end,
              {description = "pavucontrol", group = "launcher"}),

   -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()
           awful.spawn.with_shell("amixer -q -D pulse sset Master 5%-", false)
           show_volume_notification()
   end),
   awful.key({}, "XF86AudioRaiseVolume", function ()
           awful.spawn.with_shell("amixer -q -D pulse sset Master 5%+", false)
           show_volume_notification()
   end),
   awful.key({}, "XF86AudioMute", function ()
           awful.spawn.with_shell("amixer -D pulse set Master 1+ toggle", false)
           show_volume_notification()
   end),

   awful.key({modkey_alt, modkey }, "-", function ()
           awful.spawn.with_shell("amixer -q -D pulse sset Master 5%-", false)
           show_volume_notification()
   end),
   awful.key({modkey_alt, modkey }, "=", function ()
           awful.spawn.with_shell("amixer -q -D pulse sset Master 5%+", false)
           show_volume_notification()
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
   awful.key({ modkey, "Shift" }, "Print", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),
   awful.key({ modkey, }, "Print", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),

   awful.key({ modkey }, "BackSpace", function () awful.spawn.with_shell('flameshot gui') end,
     {description = "Take a screenshot of selection using flameshot", group = "screenshot"}),

    -- Rofi combi
    awful.key({ modkey, "Shift" }, "Return", function () awful.spawn.with_shell("rofi -show combi -combi-modi 'ssh,drun,window,run' -modi combi") end,
    {description = "show rofi run", group = "launcher"}),

    -- Rofi calc
    -- install this: https://github.com/svenstaro/rofi-calc
    awful.key({ modkey,           }, "space", function () awful.spawn("rofi -theme nord-two-lines -show calc -modi calc -no-show-match -no-sort -lines 1 -calc-command \"echo -n '{result}' | xclip -selection clipboard\"")                end,
              {description = "show rofi calc/converter", group = "launcher"}),

    awful.key({ modkey, }, "`", function () awful.spawn.with_shell("rofi -show window") end,
    {description = "show rofi window", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "\\", function () awful.spawn.with_shell("rofi -show ssh") end,
    {description = "show rofi ssh", group = "launcher"}),

    -- terminal
    awful.key({ modkey, }, "Return", function () awful.spawn(terminal_with_tmux) end,
        {description = "open a terminal (with tmux)", group = "launcher"}),
    awful.key({ modkey, }, "t", function () awful.spawn(terminal_with_tmux) end,
        {description = "open a terminal (with tmux)", group = "launcher"}),
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
    awful.key({ modkey, "Shift" }, "l", move_client_to_next_tag, {description = "move client to next tag", group = "layout"})
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
    -- awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
    --           {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "b", function(c) awful.titlebar.toggle(c) end, {description = 'toggle title bar', group = 'client'}), -- Toggle titlebars

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
    awful.key({ modkey,           }, "m", mymaximize , {description = "(un)maximize", group = "client"}),
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
    awful.button({ modkey }, 5, function(c) c.opacity = c.opacity - 0.1 end),
    awful.button({ modkey }, 8, function(c)
         local t = c.first_tag
         local tag = c.screen.tags[(t.index % 9) + 1]
         awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
         tag:view_only()
    end),
    awful.button({ modkey }, 9, function(c)
         local t = c.first_tag
         local tag = c.screen.tags[(t.index - 2) % 9 + 1]
         awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
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

    function mymaximizedbutton(c)
        local widget = awful.titlebar.widget.button(c, "maximized",
                                              function(cl) return cl.maximized end,
                                              function(cl, state) mymaximize(cl) end
        )
      c:connect_signal("property::maximized", widget.update)
      return widget
    end

    awful.titlebar(c, {size = 20}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.button (c, "move_to_prev_tag", function () return awful.util.get_configuration_dir() .. "/arrow-back.png" end, function ()
                                              local t = c.first_tag
                                              local tag = c.screen.tags[(t.index - 2) % 9 + 1]
                                              awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
                                              -- tag:view_only()
                                              end),
            awful.titlebar.widget.button (c, "move_to_next_tag", function () return awful.util.get_configuration_dir() .. "/arrow-forward.png" end, function ()
                                              local t = c.first_tag
                                              local tag = c.screen.tags[(t.index % 9) + 1]
                                              awful.client.movetotag(tag) -- TODO: use c:move_to_tag(target) instead
                                              -- tag:view_only()
                                              end),
            wibox.widget{markup = ' ', widget = wibox.widget.textbox},
            awful.titlebar.widget.minimizebutton (c),
            awful.titlebar.widget.stickybutton   (c),
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

client.connect_signal("focus", my_transparency_mode.focus)
client.connect_signal("unfocus", my_transparency_mode.unfocus)

-- hot corners
awful.screen.connect_for_each_screen(function(s)
  -- left
  hotcorner.create({
    screen = s,
    placement = awful.placement.top_left,
    action = function() awful.spawn("rofi -show window") end,
    -- action_2 = function() awful.spawn("pkill rofi") end -- does not work as rofi takes full screen
  })

  -- right
  hotcorner.create({
    screen = s,
    placement = awful.placement.top_right,
    action = function() awful.spawn("rofi -show window") end,
    -- action_2 = function() awful.spawn("pkill rofi") end -- does not work as rofi takes full screen
  })
end)

awful.screen.connect_for_each_screen(function(s)
    local my_right_desktop_buttons = wibox {
        visible = true,
        max_widget_size = 500,
        height = 40,
        width = 400,
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
end)

-- Wallpaper
awful.spawn.with_shell("nitrogen --restore")
-- gears.wallpaper.set("#202020")

-- Autorun/autostart programs
awful.spawn.with_shell("killall light-locker; light-locker --lock-on-lid --lock-on-suspend --no-late-locking") -- slock is introducing errors?
awful.spawn.with_shell("dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY")  -- gtk apps take ages to load without that
awful.spawn.with_shell("killall conky ; conky")
awful.spawn.with_shell("dropbox start") -- will not interfere if it's already running
awful.spawn.with_shell("xset s 3600 3600") -- 1 hour before screen blackens
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
