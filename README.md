# RTLSDR4

Docker image for RTLSDR version 4.
Includes the libraries and binaries for the version 4 
RTLSDR DTV Stick.  Works with earlier versions also.

This image is is based on Alpine Linux for the small image size.
It can be used as a base image where RTLSDR4 libraries are needed

The standard suite of RTL_* binaries are available in /usr/local/bin
Libraries can be found in /usr/local/lib

See https://github.com/dgadams/rtlsdr4 for the files and example udev 
rules and blacklist command.

## Example Docker Compose yml file:
```
# sets up a rtl_tcp server
#
# D. G. Adams 2024-Aug-28
#
# Notes:    RTL_SERIAL - Serial number of the RTL device.
#                        Don't use RTL_INDEX if RTL_SERIAL is used.
#                        Get Serial number by running any rtl command.
#                        Leading zeros in serial numbers are significant.
#           RTL_INDEX -Device index.  Depends on load order which isn't consistent.
#           RTL_ADDR - Listen address. default is 0.0.0.0
#           RTL_PORT - Listen port. default is 1234
#           RTL_GAIN - Default is 3.
#           RTL_PPM_ERROR - Default is 0.
#           RTL_FREQUENCY - Tune frequency in Hz. 
  
name: rtl-tcp
services:
  rtl-tcp:
    container_name: rtl-tcp
    image: rtlsdr4:latest
    restart: unless-stopped
    command: /usr/local/bin/rtl-tcp.sh
    devices:
      - /dev/bus/usb
    ports:
      - 1234:1234
    environment:
      - RTL_SERIAL=4
```
