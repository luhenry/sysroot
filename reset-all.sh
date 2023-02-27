#!/bin/bash

set -euxo pipefail

DIST=${DIST:-focal}

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

# Make sure everything is unmounted before we start removing anything...
for i in `seq 1 2`; do
for ARCH in ${ARCHS[@]}; do
for MOUNT in ${MOUNTS[@]}; do
sudo umount -l $(pwd)/$DIST-$ARCH$MOUNT || true
done
done
done

# Fail if there is still any mount in /sysroot
test -z "$(mount -l | grep /sysroot/$DIST)" || exit 1

exit 0
# Reset each sysroot
for ARCH in ${ARCHS[@]}; do

PKGS=(
    autoconf
    bc
    binfmt-support
    bison
    build-essential
    busybox-static
    file
    flex
    g++
    gcc
    $(test "$ARCH" = "amd64" && echo "g++-riscv64-linux-gnu" || true)
    $(test "$ARCH" = "amd64" && echo "gcc-riscv64-linux-gnu" || true)
    git
    ninja-build
    symlinks
    texinfo
    unzip
    zip
    libasound2-dev
    libatomic1
    libattr1-dev
    $(test "$DIST" = "jammy" && echo "libboost-regex1.74.0" || true)
    libc6-amd64-cross
    libc6-dbg
    libc6-riscv64-cross
    libcap-ng-dev
    libcups2-dev
    libfontconfig1-dev
    libfreetype6-dev
    libglib2.0-dev
    libpixman-1-dev
    libpng-dev
    libtinfo6
    libx11-dev
    libxext-dev
    libxrandr-dev
    libxrender-dev
    libxt-dev
    libxtst-dev
)

sudo rm -rf --one-file-system $DIST-$ARCH

sudo qemu-debootstrap --verbose --arch=$ARCH --components=main,restricted,universe --include=$(join , ${PKGS[@]}) --resolve-deps $DIST $DIST-$ARCH

sudo chroot $DIST-$ARCH symlinks -cr /

sudo chroot $DIST-$ARCH bash <<EOF
useradd -M -s /bin/bash -u 1001 ludovic
EOF

done # ARCHS


for ARCH in ${ARCHS[@]}; do
for MOUNT in ${MOUNTS[@]}; do
sudo mkdir -p $(pwd)/$DIST-$ARCH$MOUNT
sudo mount --bind $MOUNT $(pwd)/$DIST-$ARCH$MOUNT
done
done
