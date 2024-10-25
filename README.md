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
python3 tools/downsample.py files/frames_orig -O files/frames -S 25 -p 8
```

See below for `downsample.py` usage.

This should give you the following:

* `files/badapple.mp4` - The original video file.
* `files/frames_orig/badapple_*.png` - Original frames.
* `files/frames/badapple_*.png` - Downsampled frames.

### Tweaking the Frames

The original video is 1444 by 1080 pixels. This is too large for most Noita configurations. The above commands reduce the video to a quarter of that size; 361 by 270 pixels.

You can change the final size of the frames by tweaking these numbers in the `downsample.py` command. Note that there's no requirement to preserve the aspect ratio; using non-uniform width and height is supported.

In order to make the video work with Noita, it needs to be downsampled to purely black-and-white. This involves deciding on a threshold. The `downsample.py` program makes an arbitrary choice of 50%; pixels are black if their red, green, and blue components are above 127.

You can change this threshold using `-t PERCENT`. The argument needs to be a number between 0 and 100.

## Mod Usage

Note that this mod does not require unsafe mods enabled; it doesn't make use of any unsafe functions.

1. `cd Steam/steamapps/common/Noita/mods`
2. `git clone git@github.com:/Kaedenn/noita-badapple badapple`
3. `cd badapple`
4. `bash tools/download.py`
5. `python3 tools/downsample.py files/frames_orig -O files/frames -S 25 -p 8 -W air -B templebrick_static`
6. Start Noita, enable the mod, and start a new game.
7. You'll see a new spell near spawn with an apple icon. Grab it and equip it to a wand.
8. Once you're ready, cast the spell and enjoy.

## Downsample Usage

```
usage: downsample.py [-h] [--imagemagick] [-p N] [-O D] [-f] [-M N] [-t P]
                     [--white COLOR | -W MATERIAL]
                     [--black COLOR | -B MATERIAL] [-s W H | -S P] [-v]
                     path

positional arguments:
  path                  directory containing Bad Apple!! frames

optional arguments:
  -h, --help            show this help message and exit
  --imagemagick         perform operations via running ImageMagick instead of
                        using Pillow
  -p N, --pool N        run N jobs in parallel (default: 10)
  -O D, --outpath D     write frames to directory D (default: files/frames)
  -f, --regenerate      regenerate images even if they already exist
  -M N, --max N         only process the first N frames
  -v, --verbose         verbose output

color transformation:
  -t P, --threshold P   pixels below P percent are black (default: 50)
  --white COLOR         replace white pixels with COLOR (hex, rgb(), rgba())
  -W MATERIAL, --white-mat MATERIAL
                        use MATERIAL for the white pixels
  --black COLOR         replace black pixels with COLOR (hex, rgb(), rgba())
  -B MATERIAL, --black-mat MATERIAL
                        use MATERIAL for the black pixels

image sizing:
  -s W H, --size W H    rescale images to the given size in pixels
  -S P, --scale P       rescale images by P percent
```

WARNING: Player survival is not guaranteed.

