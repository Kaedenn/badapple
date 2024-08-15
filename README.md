# Bad Apple!! but it's Noita

This mod does what it says on the tin: play Bad Apple!! in Noita.

## Prerequisites

Ensure the following programs are downloaded and installed:

* [youtube-dl](http://ytdl-org.github.io/youtube-dl/)
* [ffmpeg](https://ffmpeg.org/download.html)

Ensure the Pillow Python package is installed. If not, it is _highly_ recommended to create a virtual environment and install Pillow there.

```bash
python3 -mvenv $PWD/.env
source $PWD/.env/bin/activate
python3 -m pip install Pillow
```

## Setup

Download the video, split into frames, and downsample the frames to 1 BPP (bit-per-pixel).

(Replace `8` below with the number of processor cores you want to use).

```bash
bash tools/download.sh
python3 tools/downsample.py files/frames_orig -O files/frames -s 722 540 -p 8
```

This should give you the following:

* `files/badapple.mp4` - The original video file.
* `files/frames_orig/badapple_*.png` - Original frames.
* `files/frames/badapple_*.png` - Downsampled frames.

### Tweaking the Frames

The original video is 1444 by 1080 pixels. This is too large for most Noita configurations. The above commands reduce the video to half that size; 722 by 540 pixels.

You can change the final size of the frames by tweaking these numbers in the `downsample.py` command. Note that there's no requirement to preserve the aspect ratio; using non-uniform width and height is supported.

Note that changing these values will also require changing the values at the top of `init.lua`. Specifically, change the following:

```lua
IMAGE_WIDTH = 722       -- Width of the video in pixels
IMAGE_HEIGHT = 520      -- Height of the video in pixels
```

In order to make the video work with Noita, it needs to be downsampled to purely black-and-white. This involves deciding on a threshold. The `downsample.py` program makes an arbitrary choice of 50%; pixels are black if their red, green, and blue components are above 127.

You can change this threshold using `-t PERCENT`. The argument needs to be a number between 0 and 100.

## Usage

Note that this mod does not require unsafe mods enabled; it doesn't make use of any unsafe functions.

1. `cd Steam/steamapps/common/Noita/mods`
2. `git clone git@github.com:/Kaedenn/noita-badapple badapple`
3. `cd badapple`
4. `bash tools/download.py`
5. `python3 tools/downsample.py files/frames_orig -O files/frames -s 722 540 -p 8`
6. Start Noita, enable the mod, and start a new game.
7. You'll see a new spell near spawn with an apple icon. Grab it and equip it to a wand.
8. Once you're ready, cast the spell and enjoy.

WARNING: Player survival is not guaranteed.

