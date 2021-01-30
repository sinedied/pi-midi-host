#!/usr/bin/bash

# TODO: curl

# Enable SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Prepare system
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ruby git -y

# FW for older Midisport devices
sudo apt-get install midisport-firmware -y

# Setup MIDI bluetooth
git clone https://github.com/oxesoft/bluez
sudo apt-get install -y autotools-dev libtool autoconf
sudo apt-get install -y libasound2-dev
sudo apt-get install -y libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev
cd bluez
./bootstrap
./configure --enable-midi --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var
make
sudo make install