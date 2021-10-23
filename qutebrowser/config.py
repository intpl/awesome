#!/usr/bin/env python3

config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('x', 'tab-close')
config.bind(';u', 'undo')
config.bind(';U', 'undo -w')
config.bind(';xo', 'set-cmd-text -s :open -b')
config.bind(';xO', 'set-cmd-text :open -b -r {url:pretty}')

c.editor.command = ['alacritty', '-e', 'nvim', '{file}']
