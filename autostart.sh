#!/usr/bin/env bash

function run { $@& }
function maybe_run { if ! pgrep $1 ; then $@& fi }

run "xss-lock -- i3lock -c 220000" # NOTE: add symlink to /etc/zzz.d/suspend
run "dropbox start" # will not interfere if it's already running
run "xset -dpms" # disable monitors turning off
run "xset s 3600" # 1 hour before screen blackens
# run "nitrogen --restore"

maybe_run "unclutter"
maybe_run "xbindkeys"
maybe_run "pasystray"
maybe_run "nm-applet"
# maybe_run "libinput-gestures" # freezes in Void?
maybe_run "redshift-gtk"
maybe_run "flameshot"
maybe_run "lxpolkit" # for nopasswd: /etc/polkit-1/rules.d/49-nopasswd_global.rules from https://wiki.archlinux.org/title/Polkit

pkill picom ; sleep 0.3 ; run "picom"  # picom gets weird on additional screen
