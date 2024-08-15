#!/bin/bash

# This script downloads Bad Apple!! from YouTube and dumps the frames
# to the files/frames_orig directory. The directory is created if it
# does not exist.

BASE="files"

VFILE="$BASE/badapple.mp4"
IPATH="$BASE/frames_orig"

if [[ ! -d "$BASE" ]]; then
  echo "ERROR: $BASE does not exist" >&2
  exit 1
fi

if [[ ! -d "$IPATH" ]]; then mkdir "$IPATH"; fi

set -e # Abort on the first sign of problems
youtube-dl 'https://www.youtube.com/watch?v=i41KoE0iMYU'
find . -maxdepth 1 -name '*-i41KoE0iMYU.mp4' -exec mv "{}" "$VFILE" \;
find "$IPATH" -name "badapple_*.png" -delete
ffmpeg -i "$VFILE" -r 30 "$IPATH/badapple_%04d.png"
