# pi-midi-host

> Setup a Raspberry Pi as a headless MIDI USB host.

Tested with a RPi 3B, but should work with any model. MIDI Bluetooth will only work on model 3/4 as earlier models don't have an onboard bluetooth chip.

## Usage

1. Download latest [Raspberry Pi OS lite image](https://downloads.raspberrypi.org/raspios_lite_armhf/images/) and install it on your SD card.
1. Create a new file named `ssh` in `/boot` folder of the SD card to enable SSH access.
1. SSH to your RPi with `ssh pi@<IP_ADDRESS>` (default password is `raspberry`)
1. Run this command: `bash <(curl -Ls https://raw.githubusercontent.com/sinedied/pi-midi-host/main/setup.sh)`
1. Reboot

> Note: the filesystem is switched to read-only at the end of the setup, to avoid SD card corruption when powering off. To switch it back on and off, use the `rw` and `ro` commands.

## How to connect bluetooth keyboards

1. Disable SSP mode (if needed): `sudo hciconfig hci0 sspmode 0`
1. Turn on your bluetooth device and put it in pairing mode
1. Run `sudo bluetoothctl -a`
1. `default-agent`
1. `pair <BT_ADDRESS>`
1. `trust  <BT_ADDRESS>` to allow auto reconnection
1. `connect <BT_ADDRESS>` if connection did not work
1. `exit`

## Credits

Most of this work is based on instructions from [this post](https://neuma.studio/rpi-midi-complete.html).
