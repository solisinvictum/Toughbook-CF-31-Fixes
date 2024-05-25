# Toughbook-CF-31-Fixes
Various Fixes for the Panasonic Toughbook CF-31 to fix some Issues on Linux.

This repository contains 3 fixes for the Panasonic Toughbook CF-31, which were necessary to perfect the Linux experience on this device.

These are simple bash scripts, and the audio fix in particular could certainly be fixed more elegantly directly via Pipewire or Pulseaudio. However, I had no success implementing this 100% reliably as different versions of Pipewire (from Debian and Arch for example) seem to act differently. 

Two fixes are integrated in the cf31fix.sh script. One for audio, as mentioned, and one for touchscreen. The script requires zenity and xinput_calibrator as dependencies. I got the idea for the touchscreen fix from here:

https://wiki.archlinux.org/title/Talk:Calibrating_Touchscreen#Libinput_breaks_xinput_calibrator

The last fix is a comfort fix, specifically for brightness adjustment. Under Windows, you can adjust the backlight much more precisely than under Linux. To fix this, you can set the script brightnessctl.sh with the arguments up and down as hotkeys (I deleted the original hotkeys from XFCE and added new ones).

./brightnessctl.sh up (increase brightness)
./brightnessctl.sh down (decrease brightness)
