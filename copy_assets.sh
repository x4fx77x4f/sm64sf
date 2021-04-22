#!/bin/sh
SRC="$1"
DST="${2:-$PWD}"
cp -Rn "$SRC/actors/"* "$DST/actors/"
cp -Rn "$SRC/assets/"* "$DST/assets/"
cp -Rn "$SRC/levels/"* "$DST/levels/"
cp -Rn "$SRC/sound/"* "$DST/sound/"
cp -Rn "$SRC/text/"* "$DST/text/"
