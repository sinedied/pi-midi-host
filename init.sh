#!/usr/bin/bash

sudo apt-get install git -y
git clone https://github.com/sinedied/pi-midi-host.git
cd pi-midi-host

echo "This will take a while, grab a cup of coffee..."
echo
./setup.sh
echo
echo "All done!"
echo
