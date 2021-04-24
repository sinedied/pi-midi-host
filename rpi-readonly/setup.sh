#!/bin/bash

echo "Warning: this will not ask questions, just go for it. Backups are made where it makes sense, but please don't run this on anything but a fresh install of Raspbian (stretch [lite]). Run as root ( sudo ${0} )."

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
apt install -y busybox-syslogd ntp # watchdog

echo "*Removing some unneeded software..."
apt remove -y --purge anacron logrotate dphys-swapfile rsyslog

echo "* Changing boot up parameters."
cp /boot/cmdline.txt /boot/cmdline.txt.backup
uuid=`grep '/ ' /etc/fstab | awk -F'[=]' '{print $2}' | awk '{print $1}'`
echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1 root=PARTUUID=$uuid rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait noswap ro fastboot" > /boot/cmdline.txt

echo "* Move resolv.conf to tmpfs."
mv /etc/resolv.conf /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf

#echo "* Moving pids and other files to tmpfs"
#sed -i.bak '/PIDFile/c\PIDFile=\/run\/dhcpcd.pid' /etc/systemd/system/dhcpcd5.service

rm /var/lib/systemd/random-seed && \
  ln -s /tmp/random-seed /var/lib/systemd/random-seed

cp /lib/systemd/system/systemd-random-seed.service /lib/systemd/system/systemd-random-seed.service.backup
cat > /lib/systemd/system/systemd-random-seed.service << EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.

[Unit]
Description=Load/Save Random Seed
Documentation=man:systemd-random-seed.service(8) man:random(4)
DefaultDependencies=no
RequiresMountsFor=/var/lib/systemd/random-seed
Conflicts=shutdown.target
After=systemd-remount-fs.service
Before=sysinit.target shutdown.target
ConditionVirtualization=!container

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/bin/echo '' >/tmp/random-seed
ExecStart=/lib/systemd/systemd-random-seed load
ExecStop=/lib/systemd/systemd-random-seed save
TimeoutSec=30s
EOF

systemctl daemon-reload

cp /etc/cron.hourly/fake-hwclock /etc/cron.hourly/fake-hwclock.backup
cat > /etc/cron.hourly/fake-hwclock << EOF
#!/bin/sh
#
# Simple cron script - save the current clock periodically in case of
# a power failure or other crash
 
if (command -v fake-hwclock >/dev/null 2>&1) ; then
  ro=$(mount | sed -n -e "s/^\/dev\/.* on \/ .*(\(r[w|o]\).*/\1/p")
  if [ "$ro" = "ro" ]; then
    mount -o remount,rw /
  fi
  fake-hwclock save
  if [ "$ro" = "ro" ]; then
    mount -o remount,ro /
  fi
fi
EOF

sed -i.bak '/driftfile/c\driftfile /tmp\/ntp.drift' /etc/ntp.conf

echo "* Setting up tmpfs for lightdm, in case this isn't a headless system."
ln -fs /tmp/.Xauthority /home/pi/.Xauthority
ln -fs /tmp/.xsession-errors /home/pi/.xsession-errors

echo "* Setting fs as ro in fstab (unless something is set ro already)"
if [ 0 -eq $( grep -c ',ro' /etc/fstab ) ]; then
  sed -i.bak "/boot/ s/defaults/defaults,ro/g" /etc/fstab
  sed -i "/ext4/ s/defaults/defaults,ro/g" /etc/fstab

  echo "
  tmpfs           /tmp             tmpfs   nosuid,nodev         0       0
  tmpfs           /var/log         tmpfs   nosuid,nodev         0       0
  tmpfs           /var/tmp         tmpfs   nosuid,nodev         0       0
  tmpfs           /var/lib/dhcpcd5 tmpfs   nosuid,nodev         0       0
" >> /etc/fstab
fi

echo "* Modifying bashrc"
if [ 0 -eq $( grep -c 'mount -o remount' /etc/bash.bashrc ) ]; then
  cat ./bash.bashrc.addon >> /etc/bash.bashrc
fi

touch /etc/bash.bash_logout
if [ 0 -eq $( grep -c 'mount -o remount' /etc/bash.bash_logout ) ]; then
  cat ./bash.bash_logout.addon >> /etc/bash.bash_logout
fi

echo "* Configuring kernel to auto reboot on panic."
echo "kernel.panic = 10" > /etc/sysctl.d/01-panic.conf

echo "* Disabling apt-daily and apt-daily-upgrade services"
systemctl disable apt-daily.service
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.service
systemctl disable apt-daily-upgrade.timer

echo "* Done! Reboot and hope it will come back up."

