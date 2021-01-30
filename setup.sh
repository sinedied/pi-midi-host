#!/usr/bin/bash

# Enable SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Optimize for power efficiency and fast boot
sudo cp config.txt /boot/ -y
sudo cp cmdline.txt /boot/ -y

# Prepare system
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ruby -y

# Install MIDI autoconnect script
sudo cp connectall.rb /usr/local/bin/


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