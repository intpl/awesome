#!/usr/bin/env python3

c.editor.command = ['emacsclient', '{file}', '--alternate-editor', 'kitty -e nvim']
c.auto_save.session = True
c.content.notifications.enabled = False
c.content.autoplay = False
c.url.start_pages = ["https://www.google.com/"]
c.hints.uppercase = True
c.fonts.hints = 'bold 18px Anonymous Pro Bold'
c.colors.hints.bg = 'rgb(154,205,50)'
c.colors.hints.fg = 'rgb(0,0,0)'

c.zoom.default = '120%'

config.load_autoconfig(True)
config.set("colors.webpage.darkmode.enabled", True)
config.set("colors.webpage.bg", "black")

# Search engines
c.url.searchengines["DEFAULT"] = 'https://www.google.com/search?q={}'
c.url.searchengines["g"] = 'https://www.google.com/search?q={}'
c.url.searchengines["aw"] = "https://wiki.archlinux.org/index.php?search={}"
c.url.searchengines["ddg"] = "https://duckduckgo.com/?q={}"
c.url.searchengines["e"] = "https://hexdocs.pm/elixir/search.html?q={}"
c.url.searchengines["ec"] = "https://hexdocs.pm/ecto/search.html?q={}"
c.url.searchengines["exu"] = "https://hexdocs.pm/ex_unit/search.html?q={}"
c.url.searchengines["m"] = "https://www.google.pl/maps/search/{}"
c.url.searchengines["p"] = "https://hexdocs.pm/phoenix/search.html?q={}"
c.url.searchengines["yt"] = "https://www.youtube.com/results?search_query={}"
c.url.searchengines["gh"] = "https://github.com/search?q={}"

# Binds for moving through completion items
config.bind('<Ctrl-j>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-k>', 'completion-item-focus prev', mode='command')

# The most useful keybinding here
config.bind('<Ctrl-l>', 'set-cmd-text :open {url:pretty}')

config.bind('d', 'scroll-page 0 0.5')
config.bind('W', 'tab-give')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('x', 'tab-close')
config.bind(',u', 'undo')
config.bind(',U', 'undo -w')
config.bind(',xo', 'set-cmd-text -s :open -b')
config.bind(',xO', 'set-cmd-text :open -b -r {url:pretty}')
config.bind(',e', 'edit-url')
config.bind(',E', 'config-edit')
config.bind(',p', 'open -p')
config.bind(',b', 'config-cycle statusbar.show always never ;; config-cycle tabs.show always never') # Minimal mode

# Zoom
config.bind('<ctrl-->', 'zoom-out')
config.bind('<ctrl-=>', 'zoom-in')

config.bind(',f', 'open --tab {primary}', mode='normal')

config.bind(',mf', 'hint links spawn --detach mpv {hint-url}')
config.bind(',mm', 'spawn --detach mpv {url}')

# Emacs keybiindings
config.bind('<ctrl-f>', 'fake-key <Right>', mode='normal')
config.bind('<ctrl-b>', 'fake-key <Left>', mode='normal')
config.bind('<ctrl-e>', 'fake-key <End>', mode='normal')
config.bind('<ctrl-n>', 'fake-key <Down>', mode='normal')
config.bind('<ctrl-p>', 'fake-key <Up>', mode='normal')
config.bind('<alt-f>', 'fake-key <Ctrl-Right>', mode='normal')
config.bind('<alt-b>', 'fake-key <Ctrl-Left>', mode='normal')
config.bind('<ctrl-d>', 'fake-key <Delete>', mode='normal')
config.bind('<alt-d>', 'fake-key <Ctrl-Delete>', mode='normal')
config.bind('<alt-backspace>', 'fake-key <Ctrl-Backspace>', mode='normal')
config.bind('<ctrl-y>', 'insert-text {primary}', mode='normal')

# Emacs keybediting for insert
config.bind('<ctrl-f>', 'fake-key <Right>', mode='insert')
config.bind('<ctrl-b>', 'fake-key <Left>', mode='insert')
config.bind('<ctrl-e>', 'fake-key <End>', mode='insert')
config.bind('<ctrl-n>', 'fake-key <Down>', mode='insert')
config.bind('<ctrl-p>', 'fake-key <Up>', mode='insert')
config.bind('<alt-f>', 'fake-key <Ctrl-Right>', mode='insert')
config.bind('<alt-b>', 'fake-key <Ctrl-Left>', mode='insert')
config.bind('<ctrl-d>', 'fake-key <Delete>', mode='insert')
config.bind('<alt-d>', 'fake-key <Ctrl-Delete>', mode='insert')
config.bind('<alt-backspace>', 'fake-key <Ctrl-Backspace>', mode='insert')
config.bind('<ctrl-w>', 'fake-key <Ctrl-backspace>', mode='insert')
config.bind('<ctrl-y>', 'insert-text {primary}', mode='insert')
config.bind('<ctrl-g>', 'leave-mode', mode='insert')

# Enable adblocking
config.set('content.blocking.method', 'both')

# Adblock lists
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist.to/easylist/fanboy-social.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0;hostformat=hosts",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
    "https://www.i-dont-care-about-cookies.eu/abp/",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt",
    "https://raw.githubusercontent.com/Ewpratten/youtube_ad_blocklist/master/blocklist.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext",
    "https://gitlab.com/curben/urlhaus-filter/-/raw/master/urlhaus-filter-online.txt"
]
