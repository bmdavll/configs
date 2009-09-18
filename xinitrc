#!/bin/sh

synclient TouchpadOff=1

[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

xbindkeys

if [ -x /usr/bin/tpb -a -r /dev/nvram -a -w /dev/nvram ]; then
	/usr/bin/tpb -d
fi

# exec gnome-session
# exec startkde
# exec startxfce4
exec ck-launch-session xfce4-session
