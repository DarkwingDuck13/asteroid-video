# asteroid-video

A small video player for round AsteroidOS watch screens (built for the TicWatch Pro 2020, "catfish").

This first version is also a **probe**. It reports which codecs the watch can decode and how many
frames per second really reach the screen, so you can find out what the hardware can play before
building anything bigger.

## Controls

- **Tap**: play / pause
- **Swipe left / right**: next / previous video
- **Long press**: show or hide the stats overlay (file name, fps, resolution, time, decoders)

## Putting videos on the watch

Convert on your computer (needs `ffmpeg`), then copy to `~/videos` on the watch:

```
./tools/convert.sh input.mp4 output.mp4
scp output.mp4 root@192.168.2.15:/home/root/videos/
```

The converter makes 400x400 H.264 baseline at 24 fps with 64 kbps stereo audio, about 4 MB per
minute at the default quality. Raise the third argument (crf, default 28) for smaller files, or lower
the fourth argument (fps, default 24) if playback stutters.

Or run it on a specific file: `asteroid-video /path/to/file.mp4`

## First test

1. Convert a short clip and copy it to the watch.
2. Open the app and long-press to show the stats. Check the **fps** line while it plays.
3. If the video fails, the red error text and the list of supported decoders say why.
4. If it stutters, convert again with a lower fps or a higher crf.

Useful checks over SSH:

```
ls /usr/lib/qt6/plugins/multimedia
gst-inspect-1.0 | grep -i -E "264|avdec|mp4"
```

## Building

Pushes to `main` and manual runs of the GitHub Actions workflow build an `.ipk` package
using the AsteroidOS Qt6 toolchain.
