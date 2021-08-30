#!/usr/bin/env bash

# TODO: add second argument to know what to pgrep, move unusual commands from rc.lua
function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run "blueman-applet"
run "xbindkeys"
run "compton"
run "pasystray"
run "nm-applet"
run "xfce4-volumed"
run "dropbox start"
run "redshift-gtk"
run "flameshot"
run "fusuma"
