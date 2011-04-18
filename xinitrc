#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

synclient TouchpadOff=1

xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 8 6 7 4 5

[ -x /usr/bin/tpb ] && /usr/bin/tpb -d

[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

xbindkeys

# urxvtd -q -o -f

DEFAULT_SESSION=startxfce4

case "$1" in
	xfce4)
		exec ck-launch-session startxfce4
		;;
	awesome)
		exec awesome
		;;
	gnome)
		exec gnome-session
		;;
	kde)
		exec startkde
		;;
	*)	exec ck-launch-session "$DEFAULT_SESSION"
		;;
esac

