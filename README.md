# RTLSDR4

Docker image for RTLSDR version 4.
Includes the libraries and binaries for the version 4
RTLSDR DTV Stick.  Works with earlier versions also.

This image is is based on Alpine Linux.

The standard suite of RTL_* binaries are available in /usr/local/bin
Libraries can be found in /usr/local/lib

See https://github.com/dgadams/rtlsdr4 for the files and example udev
rules and blacklist command.

## Example Docker Compose yml file:
```
# sets up a rtl_tcp server
#
# D. G. Adams 2025-March-13
#
# rtl_tcp, an I/Q spectrum server for RTL2832 based DVB-T receivers
#
#Usage:
#       [-a listen address. must be set. use  0.0.0.0 to listen all]
#       [-p listen port (default: 1234)]
#       [-f frequency to tune to [Hz]]
#       [-g gain (default: 0 for auto)]
#       [-s samplerate in Hz (default: 2048000 Hz)]
#       [-b number of buffers (default: 15, set by library)]
#       [-n max number of linked list buffers to keep (default: 500)]
#       [-d device index (default: 0)]
#       [-P ppm_error (default: 0)]
#       [-T enable bias-T on GPIO PIN 0 (works for rtl-sdr.com v3/v4 dongles)]
#       [-D enable direct sampling (default: off)]

name: rtl-tcp
services:
  rtl-tcp:
    container_name: rtl-tcp
    image: dgadams/rtlsdr4:latest
    restart: unless-stopped
    command: "rtl_tcp -d 1 -a 0.0.0.0 -p 1234"
    devices:
      - /dev/bus/usb
    ports:
      - 1234:1234
```
## Example /etc/udev/rules.d/68-RTL-SDR.rules file.  Must live on Docker host machine
```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda",  MODE:="0666"
```
## Be sure to blacklist default rtlsdr modules in linux host machine
```
sudo echo -e "\nblacklist dvb_usb_rtl28xxu\nblacklist rtl2832\nblacklist rtl2830" >> /etc/modprobe.d/blacklist.conf
```