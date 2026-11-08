# MPDC706 boot image

Buildroot recipe for a minimal Linux microSD image for the MPMAN MPDC706 tablet (INet-86DZ board, Allwinner A23). The tablet boots from the card and its internal Android storage stays untouched.

The image contains U-Boot, Linux 6.18, the touchscreen, RTL8188 Wi-Fi, speaker and front camera drivers, USB host support on the micro-USB port, `wpa_cli`, and SSH with key authentication. It contains no application and no touchscreen firmware.

## What is in this repository

| Path | Purpose |
|---|---|
| `buildroot/` | Buildroot 2026.08.1, pinned as a submodule |
| `configs/mpdc706_defconfig` | Board configuration and pinned kernel version |
| `patches/` | Kernel and U-Boot patches, plus the kernel tarball hash |
| `board/` | Kernel fragment, image layout, boot script and root filesystem overlay |

The Linux and U-Boot sources are not stored here. Buildroot downloads the pinned versions, checks their hashes and applies the patches.

## Build

Use a Linux machine with the [Buildroot system requirements](https://buildroot.org/downloads/manual/manual.html#requirement).

```bash
git clone --recurse-submodules https://github.com/srThibaultP/mpdc706-boot.git
cd mpdc706-boot
./build.sh
```

The image is written to `out/images/sdcard.img`.

## Flash

Prebuilt images are attached to the GitHub Releases. Replace `diskN` with the microSD card. This erases the card.

```bash
shasum -a 256 -c mpdc706-boot.img.xz.sha256
xz -dc mpdc706-boot.img.xz | sudo dd of=/dev/rdiskN bs=4m
```

## Configure Wi-Fi

Edit `wifi.conf` on the FAT partition. The Wi-Fi chip only supports 2.4 GHz networks. Add `country=XX` at the top of the file to set your regulatory region.

## Touchscreen firmware

The GSL1680 firmware is not included because its license is unknown. To enable the touchscreen, copy your own `gsl1680-inet86dz.fw` to the FAT partition. A community copy is available in [gsl-firmware](https://github.com/onitake/gsl-firmware).

## Hardware support

| Patch | Purpose |
|---|---|
| `0001-mpdc706-disable-mmc0-card-detect` | The card detect pin is wrong on this board, so the microSD slot is always treated as present |
| `0002-mpdc706-enable-speaker` | Enables the speaker amplifier and the audio routes |
| `0003-mpdc706-add-camera` | Describes the GC0308 front camera, the parallel camera port and their power rails |
| `0004-sun6i-csi-use-byte-addresses-on-a23` | The A23 camera port takes byte DMA addresses. Without it, frames are written to the wrong memory |
| `0005-gc0308-release-probe-runtime-pm-reference` | Lets the camera sensor power down when it is not streaming |

The front camera shows up as `/dev/video0`. Set the media pipeline formats before streaming, or the sensor outputs an empty window. The capture tools (`media-ctl`, `v4l2-ctl` from v4l-utils) are not in the image:

```bash
media-ctl -V '"gc0308 2-0021":0 [fmt:UYVY8_2X8/640x480 field:none]'
media-ctl -V '"sun6i-csi-bridge":0 [fmt:UYVY8_2X8/640x480 field:none]'
media-ctl -V '"sun6i-csi-bridge":1 [fmt:UYVY8_2X8/640x480 field:none]'
v4l2-ctl -d /dev/video0 --set-fmt-video=width=640,height=480,pixelformat=UYVY
v4l2-ctl -d /dev/video0 --stream-mmap --stream-skip=40 --stream-count=1 --stream-to=frame.uyvy
```

The stock firmware also lists a GC2035 sensor, but this tablet has no rear camera. The stock firmware lists a vibration motor on DLDO4, but the tested unit does not vibrate, so it is not described.

## USB host

The micro-USB port switches to host mode when an OTG adapter grounds its ID pin, and the AXP223 then powers the port from the battery. The kernel includes drivers for:

- USB storage, with FAT and exFAT
- USB serial adapters: CDC ACM, CH341, CP210x, FTDI and PL2303. This covers most Zigbee and Z-Wave sticks
- USB Ethernet adapters: CDC Ethernet and NCM, ASIX AX88772 and AX88179, Realtek RTL8152 and RTL8153
- Keyboards, barcode scanners and other HID devices

The port is also the charging input, so a device that draws more than the battery can supply needs an OTG adapter with power passthrough or a powered hub. Devices show up in `/sys/bus/usb/devices`. The image does not start a DHCP client on USB Ethernet adapters.

## Notes

- SSH password login is disabled. To enable SSH, put your public key in `authorized_keys` on the FAT partition.
- The boot partition is mounted read-only at `/boot`.
- The root account has no console password. Do not expose the serial or local console.

## Licenses

The image contains GPL and other open source software. Each release includes `mpdc706-boot-sources.tar` with the matching source code, patches, license texts and manifest. It also includes Realtek Wi-Fi firmware, distributed in binary form under `LICENCE.rtlwifi_firmware.txt`, which is in that archive.
