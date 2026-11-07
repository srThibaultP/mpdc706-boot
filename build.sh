#!/bin/sh
# Builds the microSD image into out/images/sdcard.img. Run on Linux.
set -e
cd "$(dirname "$0")"
git submodule update --init
make -C buildroot O="$PWD/out" BR2_EXTERNAL="$PWD" mpdc706_defconfig
make -C out
