# author:       D.G. Adams 2023-09-30
#
# builds rtlsdr version 4 as an image.
# Meant to be used as an image to build other containers
# but can be run if a CMD is specified in the docker run
# or docker compose file.
#
# libraries are in /usr/local/lib
# and rtl-* executables are in /usr/local/bin
#
FROM alpine AS build

WORKDIR /work
# bash and coreutils are only for the assembly script below (GNU cp, arrays, braces).
# They stay in this stage and never reach the final image.
RUN <<'EOR'
    apk update
    apk add libusb-dev git cmake build-base pkgconfig bash coreutils
    git clone https://github.com/rtlsdrblog/rtl-sdr-blog
    cd rtl-sdr-blog
    mkdir build
    cd build
    cmake ../
    make rtl_tcp
    make install

#   strip symbols from our own build (libusb and musl are already stripped)
    strip --strip-unneeded /usr/local/bin/rtl_tcp /usr/local/lib/librtlsdr.so.*
EOR

###################################################
# Build the final filesystem in /out by copying IN only what is needed.
# Nothing is deleted, so scratch gets a minimal, clean filesystem.
#
# Steps:  1. copy the files in
#         2. busybox applets
#         3. check that /out is self-contained

ENV OUT=/out

# ---------------------------------------------------------------
# Step 1: copy in everything on the lists below.
# The paths are relative to /, and cp --parents recreates each one under /out.
# A name that does not exist is skipped, and reported in the build log
# (look for "skipping missing").
RUN <<'EOR'
#!/bin/bash
    set -euo pipefail
    shopt -s nullglob       # unmatched globs vanish

    mkdir -p $OUT
    cd /

    BINS=( usr/local/bin/rtl_tcp  bin/busybox )

#   Every library the image needs is named here. Step 3 fails the build if one is missing.
    LIBS=(
        lib/{ld-musl*,libc.musl*}       # musl C library and loader
        usr/lib/libusb-1.0.so.*         # libusb (not the static .a that libusb-dev adds)
        usr/local/lib/librtlsdr.so*     # rtlsdr
    )

#   users for USER nobody
    DATA=( etc/{passwd,group} )

#   keep only the names that exist, and say which ones were skipped
    KEEP=()
    for p in "${BINS[@]}" "${LIBS[@]}" "${DATA[@]}"; do
        if [ -e "$p" ]; then KEEP+=("$p"); else echo "skipping missing: $p"; fi
    done

    cp -a --parents -t $OUT "${KEEP[@]}"
EOR

# ---------------------------------------------------------------
# Step 2: busybox applets. This gives the image the full set, all in /bin.
RUN /bin/busybox --install -s $OUT/bin

# ---------------------------------------------------------------
# Step 3: check /out is self-contained. Libraries are resolved against /out only,
# as in the final image. The build stops on any missing library.
RUN <<'EOR'
#!/bin/bash
    set -euo pipefail

    for f in /usr/local/bin/rtl_tcp /bin/busybox; do
        chroot $OUT /lib/ld-musl-x86_64.so.1 --list "$f" > /dev/null \
            || { echo "^ MISSING LIBS for $f"; exit 1; }
    done
EOR

##############################

FROM scratch
COPY --from=build /out/ /
USER nobody

# No startup command.  Use the compose file to specify startup.
