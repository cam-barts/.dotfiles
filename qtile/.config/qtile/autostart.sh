#!/usr/bin/env bash
# Session services for qtile (run once per login from config.py's startup_once hook).
# Plasma used to provide all of this.

# Make the compositor's env visible to D-Bus-activated services (portals, notifications).
dbus-update-activation-environment --systemd \
  WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP

# espanso's user service starts before the compositor; restart it so it sees WAYLAND_DISPLAY.
systemctl --user restart espanso.service 2>/dev/null &

WP="$HOME/Pictures/Wallpapers"
swaybg -o '*' -i "$WP/observatory-aurora-3840x2160.png" -m fill \
       -o eDP-1 -i "$WP/observatory-aurora-1366x768.png" -m fill &

mako &
lxqt-policykit-agent &
nm-applet --indicator &
blueman-applet &
keepassxc &
wl-paste --watch cliphist store &
wlsunset -S 07:00 -s 20:30 -t 4000 -T 6500 &
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/kanshi/config" ] && kanshi &

swayidle -w \
  timeout 300  'swaylock -f' \
  timeout 900  'systemctl suspend' \
  before-sleep 'swaylock -f' \
  lock         'swaylock -f' &

wait
