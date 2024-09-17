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

RUN \
    apt-get -y update && \
    apt-get -y install libusb-1.0-0-dev git cmake build-essential pkg-config && \
    git clone https://github.com/rtlsdrblog/rtl-sdr-blog
RUN \
    cd rtl-sdr-blog && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    make && \
    make install

FROM alpine:latest

WORKDIR /usr/local
COPY --from=build /usr/local/bin/ ./bin/
COPY --from=build /usr/local/lib/librtlsdr.so.0.6git ./lib/librtlsdr.so.0.6git
#COPY rtl-tcp.sh ./bin/
RUN \
    apk add libusb gcompat && \
    ln -s /usr/local/lib/librtlsdr.so.0.6git /usr/local/lib/librtlsdr.so.0 && \
    ln -s /usr/local/lib/librtlsdr.so.0 /usr/local/lib/librtlsdr.so
