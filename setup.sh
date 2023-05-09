#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

echo 'Starting setup process'
sudo apt-get update
sudo apt-get upgrade -y

echo "disable_splash=1" | sudo tee -a /boot/config.txt

echo " logo.nologo consoleblank=0 loglevel=1 quiet vt.global_cursor_default=0" | sudo tee -a /boot/cmdline.txt

sudo systemctl disable getty@tty3
sudo apt-get install fbi -y

sudo printf "[Unit]\nDescription=Splash screen\nDefaultDependencies=no\nAfter=local-fs.target\n\n[Service]\nExecStartPre=/usr/bin/sleep 2\nExecStart=/usr/bin/fbi -d /dev/fb0 --noverbose -a /home/%s/splash.png\nStandardInput=tty\nStandardOutput=tty\n\n[Install]\nWantedBy=sysinit.target" $1 | sudo tee /etc/systemd/system/splashscreen.service
sudo systemctl enable splashscreen

sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y
sudo apt-get install --no-install-recommends chromium-browser -y

sudo printf "xset s off\nxset s noblank\nxset -dpms\nsetxkbmap -option terminate:ctrl_alt_bksp\nchromium-browser --disable-infobars --kiosk '%s'" $2 | sudo tee /etc/xdg/openbox/autostart

sudo printf "[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -nocursor" | sudo tee .bash_profile

sudo raspi-config

echo 'Done.'
