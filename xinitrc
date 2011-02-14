#!/bin/sh

synclient TouchpadOff=1

xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 8 6 7 4 5

[ -x /usr/bin/tpb ] && /usr/bin/tpb -d

[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

xbindkeys

# urxvtd -q -o -f

# exec gnome-session
# exec startkde
exec ck-launch-session startxfce4
