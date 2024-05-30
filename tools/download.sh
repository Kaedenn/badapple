#!/bin/bash

# This script downloads Bad Apple!! from YouTube and dumps the frames
# to the files/frames directory. The directory is created if it does
# not exist.

BASE="files"

if [[ ! -d "$BASE" ]]; then
  echo "ERROR: $BASE does not exist" >&2
  exit 1
fi

if [[ ! -d "$BASE/frames" ]]; then mkdir "$BASE/frames"; fi

set -e # Abort on the first sign of problems
youtube-dl 'https://www.youtube.com/watch?v=i41KoE0iMYU'
find . -maxdepth 1 -name '*-i41KoE0iMYU.mp4' -exec mv "{}" "$BASE/badapple.mp4" \;
find "$BASE/frames" -name "badapple_*.png" -delete
ffmpeg -i "$BASE/badapple.mp4" -r 30 "$BASE/frames/badapple_%04d.png"
