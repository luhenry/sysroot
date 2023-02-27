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
