#!/bin/bash

SYSROOT=$1
shift

sudo chroot --userspec=1001:1001 $SYSROOT bash -c "export HOME=$(echo $HOME); cd $(pwd) && ${*@Q}"
