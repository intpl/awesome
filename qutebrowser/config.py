#!/usr/bin/env python3

c.editor.command = ['emacsclient', '{file}', '--alternate-editor', 'kitty -e nvim']
c.auto_save.session = True
c.content.notifications.enabled = False
c.content.autoplay = False
c.url.start_pages = ["https://www.google.com/"]
c.fonts.hints = 'bold 16px'

config.load_autoconfig(True)

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
