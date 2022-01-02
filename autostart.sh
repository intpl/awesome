#!/usr/bin/env bash

# TODO: add second argument to know what to pgrep, move unusual commands from rc.lua
function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run "unclutter"
run "blueman-applet"
run "xbindkeys"
run "pasystray"
run "nm-applet"
run "libinput-gestures" # freezes in Void?
run "redshift-gtk"
run "flameshot"
