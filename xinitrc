#!/bin/sh

synclient TouchpadOff=1

[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 8 6 7 4 5

xbindkeys

[ -x /usr/bin/tpb ] && /usr/bin/tpb -d

# exec gnome-session
# exec startkde
# exec startxfce4
exec ck-launch-session xfce4-session
