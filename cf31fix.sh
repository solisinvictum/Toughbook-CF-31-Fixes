#!/bin/bash
#
# Sound and Touchscreen fixes for Panasonic Toughbook CF-30 and CF-31. 
# Created by solisinvictum 04.2024
#

if [ -z "$1" ]; then

	ans=$(zenity --info --title 'Audio & Touchscreen Fix by solisinvictum' \
	--text 'Which Fix should be applied?' \
	--ok-label Audio \
	--extra-button Touchscreen)
	rc=$?
	choose="${rc}-${ans}"
	gui=1

else

	if [ $1 = "-a" ] || [ $1 = "-c" ]; then

		if [ $1 = "-a" ]; then
			choose="0-"
			gui="1"
		fi

		if [ $1 = "-c" ]; then
			choose="1-Touchscreen"
			gui="1"
		fi

	else
		
		echo "Sound and Touchscreen Fix for Panasonic Toughbook CF-30/CF-31"
		echo "Created by solisinvictum 04.2024"
		echo " "
		echo "Usage:" 
		echo " "
		echo "	Argument		Description"
		echo "	-a			Stops Audio from Muting after each restart"
		echo "	-c			Applies Fixes for the Touchscreen and calibrates it"
		exit

	fi

fi


## Audio fix
if [ $choose = "0-" ] && [ $gui = "1" ]; then

cat >/home/$(whoami)/.config/audiofix.sh <<EOL
#!/bin/bash
while [ true ]; do
var=\$(amixer -c0 get 'Headphone' | grep "Front Left" | tail -n 1 | grep -oP '[0-9]*' | head -n 2 | tail -n -1)
if [ \$var != '100' ]; then
amixer -c0 set 'Headphone',0 100%,100% on
fi
sleep 10
done
EOL

	chmod +x /home/$(whoami)/.config/audiofix.sh

cat >/home/$(whoami)/.config/systemd/user/audiofix.service <<EOL
[Unit]
Description=Audio Fix
After=default.target
After=graphical-session.target

[Service]
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$(whoami)/.Xauthority"
ExecStart=/home/$(whoami)/.config/audiofix.sh

[Install]
WantedBy=default.target
EOL

	systemctl --user enable audiofix.service

	ans=$(zenity --info --title 'Audio & Touchscreen Fix by solisinvictum' \
		--text 'Audio Fix applied.' \
		--ok-label Ok)
fi

## Touchscreen fix and calibration
if [ $choose = "1-Touchscreen" ] && [ $gui = "1" ]; then

	$(xinput set-prop "Fujitsu Component USB Touch Panel" "libinput Calibration Matrix" 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)
	xinput_calibrator -v > xinput.txt
	click0x=$(cat xinput.txt | grep "Adding click 0" | tr -d [aA-zZ:=,\(\)] | tr ' ' '\n' | tail -n 2 | head -n 1)
	click0y=$(cat xinput.txt | grep "Adding click 0" | tr -d [aA-zZ:=,\(\)] | tr ' ' '\n' | tail -n 1)
	click3x=$(cat xinput.txt | grep "Adding click 3" | tr -d [aA-zZ:=,\(\)] | tr ' ' '\n' | tail -n 2 | head -n 1)
	click3y=$(cat xinput.txt | grep "Adding click 3" | tr -d [aA-zZ:=,\(\)] | tr ' ' '\n' | tail -n 1)
	resX=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
	resY=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)

	a=$(echo "scale=5; ($resX * 6 / 8) / ($click3x - $click0x)" | bc -l)
	c=$(echo "scale=5; (($resX / 8) - ($a * $click0x)) / $resX" | bc -l | awk '{printf "%f", $0}')
	e=$(echo "scale=5; ($resY * 6 / 8) / ($click3y - $click0y)" | bc -l)
	f=$(echo "scale=5; (($resY / 8) - ($e * $click0y)) / $resY" | bc -l | awk '{printf "%f", $0}')

cat >/home/$(whoami)/.config/touchscreenfix.sh <<EOL
#!/bin/bash
SERVICE="xfce4-clipman"
while [ TRUE ]; do
sleep 5
if pgrep -x "\$SERVICE" >/dev/null
then
sleep 30
xinput set-prop "Fujitsu Component USB Touch Panel" "libinput Calibration Matrix" $a, 0.0, $c, 0.0, $e, $f, 0.0, 0.0, 1.0
exit  
fi
done
EOL

	chmod +x /home/$(whoami)/.config/touchscreenfix.sh
	$(xinput set-prop "Fujitsu Component USB Touch Panel" "libinput Calibration Matrix" $a, 0.0, $c, 0.0, $e, $f, 0.0, 0.0, 1.0)

	rm xinput.txt

cat >/home/$(whoami)/.config/systemd/user/touchscreenfix.service <<EOL
[Unit]
Description=Touchscreen Kalibrierung
After=default.target
After=graphical-session.target

[Service]
Environment="DISPLAY=:0"
Environment="XAUTHORITY=/home/$(whoami)/.Xauthority"
ExecStart=/home/$(whoami)/.config/touchscreenfix.sh

[Install]
WantedBy=default.target
EOL
	systemctl --user enable touchscreenfix.service
	ans=$(zenity --info --title 'Audio & Touchscreen Fix by solisinvictum' \
		--text 'Touchscreen Fix applied.' \
		--ok-label Ok)
fi
