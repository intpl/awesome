#!/usr/bin/env python3

c.editor.command = ['nvim-qt', '--nofork', '{file}', '--', '+normal $']
c.auto_save.session = True

config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('x', 'tab-close')
config.bind(',u', 'undo')
config.bind(',U', 'undo -w')
config.bind(',xo', 'set-cmd-text -s :open -b')
config.bind(',xO', 'set-cmd-text :open -b -r {url:pretty}')
config.bind(',e', 'edit-url')
