#!/bin/bash

set -eux -o pipefail

SYSROOT=$1
shift

sudo chroot --userspec=1001:1001 $SYSROOT bash -eux -o pipefail -c "export HOME=$(echo $HOME); cd $(pwd) && $*"
