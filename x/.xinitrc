#!/bin/bash
export $(dbus_launch --exit-with-session --exit-with-x11)

feh --bg-scale ~/Downloads/wp.png
pipewire &

while true; do
	xsetroot -rv -name " $(date +"%d-%m-%Y %H:%M") "
	sleep 5s
done &

while true; do
	dwm 2> ~/.dwm.log
done
