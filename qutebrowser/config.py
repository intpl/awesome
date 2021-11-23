#!/usr/bin/env python3

c.editor.command = ['nvim-qt', '--nofork', '{file}', '--', '+normal $']
c.auto_save.session = True
c.content.notifications.enabled = False
c.content.autoplay = False
c.url.searchengines = {'DEFAULT': 'https://www.google.com/search?q={}'}
c.url.start_pages = ["https://www.google.com/"]
c.fonts.hints = 'bold 16px'

config.load_autoconfig(True)

# Binds for moving through completion items
config.bind('<Ctrl-j>', 'completion-item-focus next', mode='command')
config.bind('<Ctrl-k>', 'completion-item-focus prev', mode='command')

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

config.bind(',f', 'open --tab {primary}', mode='normal')

config.bind(',mf', 'hint links spawn --detach mpv {hint-url}')
config.bind(',mm', 'spawn --detach mpv {url}')
