#!/bin/bash

# This script downloads Bad Apple!! from YouTube and dumps the frames
# to the ./frames directory. The directory is created if it does not
# exist.

BASE="$(dirname "$0")"

if [[ ! -d "$BASE/frames" ]]; then mkdir "$BASE/frames"; fi

youtube-dl 'https://www.youtube.com/watch?v=i41KoE0iMYU'
find . -maxdepth 1 -name '*-i41KoE0iMYU.mp4' -exec mv "{}" "$BASE/badapple.mp4" \;
find "$BASE/frames" -name "badapple_*.png" -delete
ffmpeg -i "$BASE/badapple.mp4" "$BASE/frames/badapple_%04d.png"
