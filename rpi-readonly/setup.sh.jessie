#!/bin/bash

echo "Warning: this will not ask questions, just go for it. Backups are made where it makes sense, but please don't run this on anything but a fresh install of Raspbian (jessie or jessie lite). Run as root ( sudo ${0} )."

if [ 'root' != $( whoami ) ] ; then
  echo "Please run as root!"
  exit 1;
fi

echo -n "Update apt? (Must be done on a fresh system) [y/N] "
read answer
if echo "$answer" | grep -iq "^y" ;then
  apt update || { echo "Update failed"; exit 1; }
fi

echo "* Installing some needed software..."
apt install busybox-syslogd ntp watchdog

echo "*Removing some unneeded software..."
apt remove --purge anacron logrotate dphys-swapfile rsyslog
#aptitude remove
#dpkg --purge rsyslog

echo "* Changing boot up parameters."
cp /boot/cmdline.txt /boot/cmdline.txt.backup
echo "dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait fastboot noswap ro" > /boot/cmdline.txt

echo "* Removing some directories, and linking to tmpfs."
rm -rf /var/lib/dhcp/ /var/run /var/lock /etc/resolv.conf
ln -s /tmp /var/lib/dhcp
ln -s /tmp /var/run
ln -s /tmp /var/spool
ln -s /tmp /var/lock
touch /tmp/dhcpcd.resolv.conf;
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf

echo "* Moving pids and other files to tmpfs"
cp /etc/systemd/system/dhcpcd5 /etc/systemd/system/dhcpcd5.backup && \
  sed -i '/PIDFile/c\PIDFile=\/var\/run\/dhcpcd.pid' /etc/systemd/system/dhcpcd5

rm /var/lib/systemd/random-seed && \
  ln -s /tmp/random-seed /var/lib/systemd/random-seed

cp /lib/systemd/system/systemd-random-seed.service /lib/systemd/system/systemd-random-seed.service.backup
cat > /lib/systemd/system/systemd-random-seed.service << EOF
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/bin/echo '' >/tmp/random-seed
ExecStart=/lib/systemd/systemd-random-seed load
ExecStop=/lib/systemd/systemd-random-seed save
EOF

systemctl daemon-reload

cp /etc/cron.hourly/fake-hwclock /etc/cron.hourly/fake-hwclock.backup
cat > /etc/cron.hourly/fake-hwclock << EOF
#!/bin/sh
#
# Simple cron script - save the current clock periodically in case of
# a power failure or other crash
 
if (command -v fake-hwclock >/dev/null 2>&1) ; then
  mount -o remount,rw /
  fake-hwclock save
  mount -o remount,ro /
fi
EOF

cp /etc/ntp.conf /etc/ntp.conf.backup
sed -i '/driftfile/c\driftfile \/var\/tmp\/ntp.drift' /etc/ntp.conf

#echo "* Disabling bootlofs, console-setup"
#insserv -r bootlogs
#insserv -r console-setup

echo "* Setting up tmpfs for lightdm, in case this isn't a headless system."
#TODO: lightdm config:
# set user-authority-in-system-dir=true in /etc/lightdm/lightdm.conf
mkdir -p /var/lib/lightdm

echo "* Setting fs as ro in fstab"
if [ 0 -eq $( grep -c ',ro' /etc/fstab ) ]; then
  cp /etc/fstab /etc/fstab.backup
  sed -i "/boot/ s/defaults/defaults,ro/g" /etc/fstab
  sed -i "/ext4/ s/defaults/defaults,ro/g" /etc/fstab

  echo "
  tmpfs           /tmp            tmpfs   nosuid,nodev         0       0
  tmpfs           /var/log        tmpfs   nosuid,nodev         0       0
  tmpfs           /var/lib/lightdm        tmpfs   nosuid,nodev         0       0
  tmpfs           /var/tmp        tmpfs   nosuid,nodev         0       0" >> /etc/fstab
fi

echo "* Modifying bash rc"
if [ 0 -eq $( grep -c 'mount -o remount' /etc/bash.bashrc ) ]; then
  cat ./bash.bashrc.addon >> /etc/bash.bashrc
fi

touch /etc/bash.bash_logout
if [ 0 -eq $( grep -c 'mount -o remount' /etc/bash.bash_logout ) ]; then
  cat ./bash.bash_logout.addon >> /etc/bash.bash_logout
fi

echo "* Configuring watchdog"

if [ 0 -eq $( grep -c 'watchdog-timeout = 10' /etc/watchdog.conf ) ]; then
  echo "watchdog-device  = /dev/watchdog
  max-load-15      = 25  
  watchdog-timeout = 10" >> /etc/watchdog.conf
fi

echo "options bcm2835_wdt nowayout=1" > /etc/modprobe.d/watchdog.conf

echo "* Watchdog installed, but not enabled. To enable, run sudo systemctl enable watchdog"

#TODO: systemd watchdog? make repeatable
#echo "WantedBy=multi-user.target" >> /lib/systemd/system/watchdog.service

echo "* Configuring kernel to auto reboot on panic."
echo "kernel.panic = 10" > /etc/sysctl.d/01-panic.conf

echo "* Done! Reboot and hope it will come back up."

