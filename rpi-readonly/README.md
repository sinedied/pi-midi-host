# rpi-readonly
Make raspberry pi raspbian file system read-only

Based on https://hallard.me/raspberry-pi-read-only/

* for debian buster, the sudo/ts line has been removed from fstab.
* setup.sh - Tested OK on 2017-11-29-raspbian-stretch*.img
* Old version named setup.sh.jessie - Tested OK on 2017-04-10-raspbian-jessie*.img

TODO:
* Check if https://github.com/MarkDurbin104/rPi-ReadOnly has anything I'm missing.
* Watchdog

Tricks for certain apps:
* Apache2, edit logpath in /etc/apache2/env
* Chromium-browser, use --user-data-dir /tmp/something
* Lightdm - fixed via setup.sh
* Rpi-Cam-Web-Interface: mount /var/www/html/media/ on tmpfs or external rw disk

Usage after setup:
* If you need to change anything, run rw to remount file system read/write. Then ro to make it read only.
* Logs can be read with the command readlog and readlog -f.
