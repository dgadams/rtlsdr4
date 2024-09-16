#
# author:	D.G. Adams 2023-09-30
#
# builds rtlsdr version 4 as an image.  
# Meant to be used as an image to build other containers
# but can be run if a CMD is specified in the docker run 
# or docker compose file.  
#
# libraries are in /usr/local/lib
# and rtl-* executables are in /usr/local/bin
# 

FROM debian:bookworm-slim AS build

WORKDIR /work

RUN <<EOR
    apt-get -y update && \
    apt-get -y install libusb-1.0-0-dev git cmake build-essential pkg-config && \
    git clone https://github.com/rtlsdrblog/rtl-sdr-blog

    cd rtl-sdr-blog
    mkdir build
    cd build
    cmake ../
    make
    make install

    cat <<EOF >/usr/local/bin/rtl-tcp.sh
#!/bin/sh
set -e
if [ -n $RTL_SERIAL ]; then
    RTL_INDEX=$(rtl_tcp -d9999 2>&1 | grep -o "\d.*SN: $RTL_SERIAL" | cut -c1-1)
fi

exec /usr/local/bin/rtl_tcp \
    -a ${RTL_ADDR-0.0.0.0} \
    -p ${RTL_PORT-1234} \
    -g ${RTL_GAIN-3} \
    -d ${RTL_INDEX-0} \
    -P ${RTL_PPM_ERROR-0} \
    -f ${RTL_FREQUENCY-95500000}
EOF
EOR
###############################

FROM alpine:latest

WORKDIR /usr/local/lib
COPY --from=build /usr/local/bin/* ../bin
COPY --from=build /usr/local/lib/librtlsdr.so.0.6git .

RUN <<EOR
    apk add --no-cache libusb gcompat
    ln -s librtlsdr.so.0.6git librtlsdr.so.0
    ln -s /librtlsdr.so.0 librtlsdr.so
    adduser -D sdr
    adduser sdr sdr
    cd /
EOR
USER sdr
