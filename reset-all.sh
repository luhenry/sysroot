#!/bin/bash

set -euxo pipefail

DIST=focal

ARCHS=(
    amd64
    riscv64
)

MOUNTS=(
    /proc
    /dev
    /sys
    /rivos
    /workspace
    /sysroot
)

function join { local IFS="$1"; shift; echo "$*"; }

for ARCH in ${ARCHS[@]}; do

PKGS=(
    autoconf
    build-essential
    git
    ninja-build
    symlinks
    file
    zip
    unzip
    gcc
    g++
    $(test "$ARCH" = "amd64" && echo "gcc-riscv64-linux-gnu" || true)
    $(test "$ARCH" = "amd64" && echo "g++-riscv64-linux-gnu" || true)
    libasound2-dev
    libatomic1
    $(test "$DIST" = "jammy" && echo "libboost-regex1.74.0" || true)
    libc6-dbg
    libc6-amd64-cross
    libc6-riscv64-cross
    libcups2-dev
    libfontconfig1-dev
    libfreetype6-dev
    libglib2.0-dev
    libpixman-1-dev
    libpng-dev
    libx11-dev
    libxext-dev
    libxrandr-dev
    libxrender-dev
    libxt-dev
    libxtst-dev
)

for MOUNT in ${MOUNTS[@]}; do
sudo umount $(pwd)/$DIST-$ARCH$MOUNT || true
done

sudo rm -rf --one-file-system $DIST-$ARCH

sudo qemu-debootstrap --verbose --arch=$ARCH --components=main,restricted,universe --include=$(join , ${PKGS[@]}) --resolve-deps $DIST $DIST-$ARCH

sudo chroot $DIST-$ARCH symlinks -cr /

sudo chroot $DIST-$ARCH bash <<EOF
useradd -M -s /bin/bash -u 1001 ludovic
EOF

for MOUNT in ${MOUNTS[@]}; do
sudo mkdir -p $(pwd)/$DIST-$ARCH$MOUNT
sudo mount --bind $MOUNT $(pwd)/$DIST-$ARCH$MOUNT
done

done # ARCHS