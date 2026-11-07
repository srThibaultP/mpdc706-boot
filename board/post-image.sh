#!/bin/sh
set -e
B="$(dirname "$0")"
cp "$B/wifi.conf" "$BINARIES_DIR/wifi.conf"
cp "$BINARIES_DIR/allwinner/sun8i-a23-inet86dz.dtb" "$BINARIES_DIR/" 2>/dev/null || true
support/scripts/genimage.sh -c "$B/genimage.cfg"
