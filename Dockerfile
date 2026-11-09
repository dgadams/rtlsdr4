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
FROM alpine AS build1

WORKDIR /work
RUN <<EOR
    apk update
    apk add libusb-dev git cmake build-base pkgconfig 
    git clone https://github.com/rtlsdrblog/rtl-sdr-blog
    cd rtl-sdr-blog
    mkdir build
    cd build
    cmake ../
    make rtl_tcp
    make install
EOR

FROM alpine AS muntz

COPY --from=build1 /usr/local /usr/local

RUN <<EOR
    apk update
    apk add libusb bash

    /bin/bash <<END_BASH
        shopt -s extglob        # bash extension to allow rf !(...)

#       Remove files/directories except those needed
        cd /                && rm -rf !(dev|run|usr|bin|etc|sbin|lib|sys)
        cd /usr             && rm -rf !(bin|sbin|lib|local)
        cd /usr/lib         && rm -rf !(libusb*)
        cd /usr/local       && rm -rf !(bin|lib)
        cd /usr/local/lib   && rm -rf !(librtlsdr.so*)
        cd /usr/local/bin   && rm -rf !(rtl_tcp)
        cd /lib             && rm -rf !(libc*|ld-musl*)
        cd /etc             && rm -rf !(group|passwd)
        rm /sbin/apk
        cd /usr/bin && rm getconf getent iconv ldd scanelf ssl_client

END_BASH
    rm /bin/bash
EOR
##############################

FROM scratch
COPY --from=muntz / /
USER nobody

# No startup command.  Use the compose file to specify startup.
