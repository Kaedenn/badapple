#!/usr/bin/env python3

"""
Downsample the Bad Apple!! frames to 1bpp
"""

import argparse
import glob
import logging
import os
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

def downsample_one_runner(args):
  "Processor function invoked by multiprocessing"
  return downsample_one(*args)

def downsample_one(fimg, threshold, newsize, outpath):
  "Downsample a single image"
  ofname = fimg
  if outpath:
    ofname = os.path.join(outpath, os.path.basename(fimg))
    if os.path.exists(ofname):
      logger.debug("Skipping %s", fimg)
      return
  logger.info("Processing %s", fimg)
  cutoff = 255 * threshold / 100
  nwhite, nblack = 0, 0
  img = Image.open(fimg)
  if newsize:
    img = img.resize(newsize, Image.NEAREST)
  npixels = img.width * img.height
  for px in range(img.width):
    for py in range(img.height):
      pixel = img.getpixel((px, py))
      if len(set(pixel)) != 1:
        logger.warning("%s: pixel at (%d, %d) not monochrome", fimg, px, py)
        continue
      pvalue = pixel[0]
      if pvalue >= cutoff and pixel != WHITE:
        img.putpixel((px, py), WHITE)
        nwhite += 1
      elif pvalue < cutoff and pixel != BLACK:
        img.putpixel((px, py), BLACK)
        nblack += 1
  save_file = False
  if fimg != ofname:
    save_file = True
  if nwhite > 0 or nblack > 0:
    logger.debug("Adjusted %d pixels (%0.2f) of %s to white", nwhite, nwhite*100/npixels, fimg)
    logger.debug("Adjusted %d pixels (%0.2f) of %s to black", nblack, nblack*100/npixels, fimg)
    save_file = True
  if save_file:
    img.save(ofname)

def main():
  ap = argparse.ArgumentParser()
  ap.add_argument("path", help="directory containing Bad Apple!! frames")
  ap.add_argument("-p", "--pool", type=int, metavar="NUM", default=10,
      help="run %(metavar)s jobs in parallel (default: %(default)s)")
  ap.add_argument("-O", "--outpath", metavar="DIR",
      help="write frames to %(metavar)s (default: in-place)")
  ap.add_argument("-t", "--threshold", type=int, metavar="P", default=50,
      help="pixels below %(metavar)s percent are black (default: %(default)s)")
  ap.add_argument("-s", "--size", type=int, nargs=2, metavar=("W", "H"),
      help="rescale images to the given size")
  ap.add_argument("-v", "--verbose", action="store_true", help="verbose output")
  args = ap.parse_args()
  if args.verbose:
    logger.setLevel(logging.DEBUG)

  frames = glob.glob(os.path.join(args.path, "badapple_*.png"))
  frames.sort(key=lambda fpath: filename_to_frame(os.path.basename(fpath)))
  nframes = len(frames)
  logger.debug("Processing %d images", nframes)

  pool = multiprocessing.Pool(args.pool)
  jobs = [(fimg, args.threshold, args.size, args.outpath) for fimg in frames]
  for _ in pool.map(downsample_one_runner, jobs):
    pass

if __name__ == "__main__":
  main()

# vim: set ts=2 sts=2 sw=2:
