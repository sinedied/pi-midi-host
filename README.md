# pi-midi-host

> Setup a Raspberry Pi as a headless MIDI USB host.

Tested with a RPi 3B, but should work with any model. MIDI Bluetooth will only work on model 3/4 as earlier models don't have an onboard bluetooth chip.

## Usage

1. Download latest [Raspberry Pi OS lite image](https://downloads.raspberrypi.org/raspios_lite_armhf/images/) and install it on your SD card.

2. Create a new file named `ssh` in `/boot` folder of the SD card to enable SSH access.

3. SSH to your RPi with `ssh pi@<IP_ADDRESS>` (default password is `raspberry`)

4. Run this command: `curl ...`

5. Reboot

