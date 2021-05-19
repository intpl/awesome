#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run "blueman-applet"
run "xbindkeys"
run "compton"
run "cbatticon"
run "pasystray"
run "nm-applet"
run "xfce4-volumed"
run "dropbox start"
