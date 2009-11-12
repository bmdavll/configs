#!/bin/sh

synclient TouchpadOff=1

[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

xbindkeys

[ -x /usr/bin/tpb ] && /usr/bin/tpb -d

# exec gnome-session
# exec startkde
# exec startxfce4
exec ck-launch-session xfce4-session
