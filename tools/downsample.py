#!/usr/bin/env python3

"""
Downsample the Bad Apple!! frames to 1bpp
"""

import argparse
import glob
import logging
import os
import subprocess
import sys

import multiprocessing

from PIL import Image

logging.basicConfig(format="%(module)s:%(lineno)s: %(levelname)s: %(message)s",
                    level=logging.INFO)
logger = logging.getLogger(__name__)

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

def filename_to_frame(filename):
  "Extract frame number from the filename"
  base = os.path.splitext(filename)[0]
  return int(base.split("_")[-1], 16)

def parse_color(color_arg):
  "Parse a command-line color"
  if color_arg.startswith("#"):
    color = []
    color_arg = color_arg[1:]
    while color_arg:
      color.append(int(color_arg[:2], 16))
      color_arg = color_arg[2:]
    return tuple(color)
  if color_arg.startswith("rgb(") and color_arg.endswith(")"):
    return tuple(int(part.strip()) for part in color_arg[4:-1].split(","))
  if color_arg.startswith("rgba(") and color_arg.endswith(")"):
    return tuple(int(part.strip()) for part in color_arg[5:-1].split(","))
  if color_arg.count(",") >= 2:
    return tuple(int(part) for part in color_arg.split(","))
  raise ValueError(f"Failed to parse color {color_arg!r}")

def color_to_rgba(color):
  "Convert a color triple or quadruple to a color argument"
  if len(color) == 3:
    return "#" + "".join(f"{part:02x}" for part in color)
  return "rgba({})".format(",".join(str(part) for part in color))

def downsample_one_runner(job):
  "Processor function invoked by multiprocessing"
  runner = downsample_one
  if job.get("runner", "") == "imagemagick":
    runner = downsample_im_one
  logger.debug("Invoking job %r", job)
  return runner(
      fimg=job["path"],
      threshold=job["threshold"],
      newsize=job["size"],
      outpath=job["outpath"],
      white=job.get("white", WHITE),
      black=job.get("black", BLACK),
      regenerate=job.get("regenerate", False))

def downsample_im_one(fimg, threshold, newsize, outpath, white=WHITE, black=BLACK, regenerate=False):
  "Downsample a single image using ImageMagick"
  ofname = fimg
  if outpath:
    ofname = os.path.join(outpath, os.path.basename(fimg))
    if os.path.exists(ofname) and not regenerate:
      logger.debug("Skipping %s", fimg)
      return

  fuzz_arg = f"{threshold}%"
  white_opaque = color_to_hex(WHITE)
  black_opaque = color_to_hex(BLACK)
  white_fill = color_to_hex(white)
  black_fill = color_to_hex(black)

  args = ["convert", fimg,
      "-fuzz", fuzz_arg, "-fill", white_fill, "-opaque", white_opaque,
      "-fuzz", fuzz_arg, "-fill", black_fill, "-opaque", black_opaque]
  if newsize:
    if len(newsize) == 1:
      args.extend(("-scale", f"{newsize[0]}%"))
    else:
      args.append(("-scale", f"{newsize[0]}x{newsize[1]}"))
  args.append(ofname)

  logger.info("Processing %s", fimg)
  logger.debug(subprocess.list2cmdline(args))

  subprocess.check_call(args)

def downsample_one(fimg, threshold, newsize, outpath, white=WHITE, black=BLACK, regenerate=False):
  "Downsample a single image"
  ofname = fimg
  if outpath:
    ofname = os.path.join(outpath, os.path.basename(fimg))
    if os.path.exists(ofname) and not regenerate:
      logger.debug("Skipping %s", fimg)
      return
  logger.info("Processing %s", fimg)
  cutoff = 255 * threshold / 100
  nwhite, nblack = 0, 0
  img = Image.open(fimg)
  if newsize:
    if len(newsize) == 1:
      scale = newsize[0]/100
      newwidth = int(img.width * scale)
      newheight = int(img.height * scale)
    elif len(newsize) == 2:
      newwidth, newheight = newsize
    else:
      raise ValueError(f"Invalid size arg {newsize!r}")
    img = img.resize((newwidth, newheight), Image.NEAREST)
  npixels = img.width * img.height

  if len(white) == 4 or len(black) == 4:
    img = img.convert("RGBA")

  for px in range(img.width):
    for py in range(img.height):
      pixel = img.getpixel((px, py))[:3]
      if len(set(pixel)) != 1:
        logger.warning("%s: pixel at (%d, %d) %s not monochrome", fimg, px, py, pixel)
        continue
      pvalue = pixel[0]
      if pvalue >= cutoff and pixel != WHITE:
        img.putpixel((px, py), white)
        nwhite += 1
      elif pvalue < cutoff and pixel != BLACK:
        img.putpixel((px, py), black)
        nblack += 1
      elif pixel == WHITE and pixel != white:
        img.putpixel((px, py), white)
        nwhite += 1
      elif pixel == BLACK and pixel != black:
        img.putpixel((px, py), black)
        nblack += 1

  save_file = False
  if fimg != ofname:
    save_file = True
  if nwhite > 0 or nblack > 0:
    logger.debug("Adjusted %d pixels (%0.2f) of %s to %s", nwhite, nwhite*100/npixels, fimg, white)
    logger.debug("Adjusted %d pixels (%0.2f) of %s to %s", nblack, nblack*100/npixels, fimg, black)
    save_file = True
  if save_file:
    img.save(ofname)

def main():
  ap = argparse.ArgumentParser()
  ap.add_argument("path", help="directory containing Bad Apple!! frames")
  ap.add_argument("--imagemagick", action="store_true",
      help="perform operations via running ImageMagick instead of using Pillow")
  ap.add_argument("-p", "--pool", type=int, metavar="NUM", default=10,
      help="run %(metavar)s jobs in parallel (default: %(default)s)")
  ap.add_argument("-O", "--outpath", metavar="DIR",
      help="write frames to %(metavar)s (default: in-place)")
  ap.add_argument("-t", "--threshold", type=int, metavar="P", default=50,
      help="pixels below %(metavar)s percent are black (default: %(default)s)")
  ap.add_argument("--white", metavar="COLOR",
      help="replace white pixels with %(metavar)s")
  ap.add_argument("--black", metavar="COLOR",
      help="replace black pixels with %(metavar)s")
  ap.add_argument("-f", "--regenerate", action="store_true",
      help="regenerate images even if they already exist")
  ap.add_argument("--max", type=int, metavar="NUM",
      help="only process the first %(metavar)s frames")
  mg = ap.add_mutually_exclusive_group()
  mg.add_argument("-s", "--size", type=int, nargs=2, metavar=("W", "H"),
      help="rescale images to the given size in pixels")
  mg.add_argument("-S", "--scale", type=int, metavar="P",
      help="rescale images by %(metavar)s percent")
  ap.add_argument("-v", "--verbose", action="store_true", help="verbose output")
  args = ap.parse_args()
  if args.verbose:
    logger.setLevel(logging.DEBUG)

  frames = glob.glob(os.path.join(args.path, "badapple_*.png"))
  frames.sort(key=lambda fpath: filename_to_frame(os.path.basename(fpath)))
  if args.max and args.max < len(frames):
    logger.info("Processing only the first %d frames", args.max)
    frames = frames[:args.max]
  nframes = len(frames)
  logger.debug("Processing %d images", nframes)

  size_arg = None
  if args.size:
    size_arg = args.size
  elif args.scale:
    size_arg = (args.scale,)

  runner = "default"
  if args.imagemagick:
    runner = "imagemagick"

  pool = multiprocessing.Pool(args.pool)
  jobs = [dict(
    runner = runner,
    path = fimg,
    threshold = args.threshold,
    size = size_arg,
    outpath = args.outpath,
    white = parse_color(args.white) if args.white else WHITE,
    black = parse_color(args.black) if args.black else BLACK,
    regenerate = args.regenerate,
  ) for fimg in frames]
  for _ in pool.map(downsample_one_runner, jobs):
    pass

if __name__ == "__main__":
  main()

# vim: set ts=2 sts=2 sw=2:
