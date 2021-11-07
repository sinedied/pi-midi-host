#!/usr/bin/bash

# Set new user password
echo "First, let's set a new password for better security!"
passwd

# Enable SSH
sudo systemctl enable ssh
sudo systemctl start ssh

# Optimize for power efficiency and fast boot
sudo cp config.txt /boot/ -y
sudo cp cmdline.txt /boot/ -y

# Prepare system
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install git ruby -y

# Clone this repo
git clone https://github.com/sinedied/pi-midi-host
cd pi-midi-host

# Install MIDI autoconnect script
sudo cp connectall.rb /usr/local/bin/
sudo cp 33-midiusb.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo service udev restart
sudo cp midi.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable midi.service
sudo systemctl start midi.service

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
cd ..
sudo cp 44-bt.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo service udev restart
sudo cp btmidi.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable btmidi.service
sudo systemctl start btmidi.service

# Create alias to show connected devices
echo >> ~/.bashrc
echo "alias midi='aconnect -l'" >> ~/.bashrc
echo >> ~/.bashrc

# Create alias to reconnect devices
echo >> ~/.bashrc
echo "alias connect='connectall.rb'" >> ~/.bashrc
echo >> ~/.bashrc

# Make FS read-only to avoid SD card corruption
git clone https://gitlab.com/larsfp/rpi-readonly
cd rpi-readonly
sudo ./setup.sh -y
cd ..

# Turn on read-only mode
# Use command "rw" to enable writes again
ro
