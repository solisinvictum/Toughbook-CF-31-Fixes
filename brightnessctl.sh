#!/bin/bash
#Helligkeitkontroller für Panasonic Toughbook CF-30 und CF-31

if [ -z "$1" ]; then
	echo "Kein Wert vorhanden"
	exit
fi
#Helligkeit hoch
if [ "$1" = "up" ]; then
	
	var=$(cat /sys/class/backlight/intel_backlight/brightness)	

	if [ "$var" = "0" ]; then
		var=1
	fi
	var=$(echo $var*2 | bc)
	if [ "$var" -gt 1415 ]; then
		var=1415
	fi

	$(echo $var > /sys/class/backlight/intel_backlight/brightness)
fi

#Helligkeit runter
if [ "$1" = "down" ]; then
	
	var=$(cat /sys/class/backlight/intel_backlight/brightness)	
	
	if [ "$var" = "2" ] || [ "$var" = "0" ]; then
		var=0
	else 
		var=$(echo $var/2 | bc)
		if [ "$var" -lt 2 ]; then
			var=2
		fi
	fi
	$(echo $var > /sys/class/backlight/intel_backlight/brightness)

fi
