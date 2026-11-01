#!/bin/sh
# Convert any video into a small, easy-to-decode file for a round watch screen.
#
#   ./tools/convert.sh input.mp4 output.mp4 [crf] [fps]
#
# 400x400, H.264 baseline, AAC 64k. Raise crf (default 28) for smaller files.
# The picture is cropped to a square from the center. Lower fps (default 24)
# if playback stutters on the watch.
set -e
in="$1"; out="$2"; crf="${3:-28}"; fps="${4:-24}"
[ -n "$in" ] && [ -n "$out" ] || { echo "usage: $0 input output [crf] [fps]"; exit 1; }
ffmpeg -i "$in" \
  -vf "scale=400:400:force_original_aspect_ratio=increase,crop=400:400,fps=$fps" \
  -c:v libx264 -profile:v baseline -level 3.0 -preset slow -crf "$crf" \
  -maxrate 500k -bufsize 1M -pix_fmt yuv420p \
  -c:a aac -b:a 64k -ac 2 -movflags +faststart \
  "$out"
