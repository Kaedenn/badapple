#!/usr/bin/env python3

"""
Downsample the Bad Apple!! frames to 1bpp
"""

# TODO: Incorporate feedback (failures, stats) to the progress message
# TODO: Allow non-square resizing (keep aspect ratio, add borders)
#new_img = ImageOps.expand(img, border=(pad_width, 0, pad_width, 0), fill='white')

import argparse
import csv
import glob
import logging
import os
import subprocess
import sys

import multiprocessing

from PIL import Image

MATERIAL_FILE_PATH = os.path.join(os.path.dirname(sys.argv[0]), "materials.csv")
POOL_DEFAULT = 10
THRESH_DEFAULT = 50

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

def color_to_hex(color):
  "Convert a color triple or quadruple to a hexadecimal RGBA value"
  return "".join(f"{part:02x}" for part in color)

def color_to_rgba(color):
  "Convert a color triple or quadruple to a color argument"
  if len(color) == 3:
    return "rgb({})".format(",".join(str(part) for part in color))
  return "rgba({})".format(",".join(str(part) for part in color))

def downsample_im_one(fimg, threshold, newsize, ofname, white=WHITE, black=BLACK):
  "Downsample a single image using ImageMagick"
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
  logger.debug(subprocess.list2cmdline(args))
  subprocess.check_call(args)

def downsample_pil_one(fimg, threshold, newsize, ofname, white=WHITE, black=BLACK):
  "Downsample a single image"
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
    logger.debug("Adjusted %d pixels (%0.2f) of %s to %s",
        nwhite, nwhite*100/npixels, fimg, white)
    logger.debug("Adjusted %d pixels (%0.2f) of %s to %s",
        nblack, nblack*100/npixels, fimg, black)
    save_file = True
  if save_file:
    img.save(ofname)

def downsample_one_runner(job, queue):
  "Processor function invoked by multiprocessing"
  runner = downsample_pil_one
  if job.get("runner", "") == "imagemagick":
    runner = downsample_im_one
  logger.debug("Invoking job %r", job)

  fimg = job["path"]
  threshold = job["threshold"]
  newsize = job["size"]
  outpath = job["outpath"]
  white = job.get("white", WHITE)
  black = job.get("black", BLACK)
  regenerate = job.get("regenerate", False)

  ofname = os.path.join(outpath, os.path.basename(fimg))
  if not os.path.exists(ofname) or regenerate:
    runner(
        fimg=fimg,
        threshold=threshold,
        newsize=newsize,
        ofname=ofname,
        white=white,
        black=black)

  queue.put(fimg)

def monitor_process(queue, total):
  "Monitor the progress of the downsampling"
  completed = 0
  while completed < total:
    last_filename = queue.get()
    completed += 1
    logger.info("Progress: %d/%d (%d%%) %s",
        completed, total,
        completed/total*100,
        last_filename)

def get_color_for_material(matname):
  "Determine the color for the given material"
  with open(MATERIAL_FILE_PATH, "rt") as fobj:
    for row in csv.reader(fobj):
      argb_str, mat_name = row
      if matname == mat_name:
        cla, clr, clg, clb = parse_color("#" + argb_str)
        return (clr, clg, clb, cla)
  return None

def main():
  ap = argparse.ArgumentParser()
  ap.add_argument("path", help="directory containing Bad Apple!! frames")
  ap.add_argument("--imagemagick", action="store_true",
      help="perform operations via running ImageMagick instead of using Pillow")
  ap.add_argument("-p", "--pool", type=int, metavar="N", default=POOL_DEFAULT,
      help="run %(metavar)s jobs in parallel (default: %(default)s)")
  ap.add_argument("-O", "--outpath", metavar="D", default="files/frames",
      help="write frames to directory %(metavar)s (default: %(default)s)")
  ap.add_argument("-f", "--regenerate", action="store_true",
      help="regenerate images even if they already exist")
  ap.add_argument("-M", "--max", type=int, metavar="N",
      help="only process the first %(metavar)s frames")
  ag = ap.add_argument_group("color transformation")
  ag.add_argument("-t", "--threshold", type=int, metavar="P", default=THRESH_DEFAULT,
      help="pixels below %(metavar)s percent are black (default: %(default)s)")
  mg = ag.add_mutually_exclusive_group()
  mg.add_argument("--white", metavar="COLOR",
      help="replace white pixels with %(metavar)s (hex, rgb(), rgba())")
  mg.add_argument("-W", "--white-mat", metavar="MATERIAL",
      help="use %(metavar)s for the white pixels")
  mg = ag.add_mutually_exclusive_group()
  mg.add_argument("--black", metavar="COLOR",
      help="replace black pixels with %(metavar)s (hex, rgb(), rgba())")
  mg.add_argument("-B", "--black-mat", metavar="MATERIAL",
      help="use %(metavar)s for the black pixels")
  ag = ap.add_argument_group("image sizing")
  mg = ag.add_mutually_exclusive_group()
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

  if args.outpath:
    if not os.path.exists(args.outpath):
      logger.info("Creating directory %s", args.outpath)
      os.makedirs(args.outpath)

  runner = "default"
  if args.imagemagick:
    runner = "imagemagick"

  pool = multiprocessing.Pool(args.pool)
  manager = multiprocessing.Manager()
  queue = manager.Queue()

  monitor = multiprocessing.Process(target=monitor_process, args=(queue, nframes))
  monitor.start()

  white_color = WHITE
  if args.white:
    white_color = parse_color(args.white)
  elif args.white_mat:
    white_color = get_color_for_material(args.white_mat)
    if not white_color:
      ap.error(f"Invalid or unknown material {args.white_mat!r}")

  black_color = WHITE
  if args.black:
    black_color = parse_color(args.black)
  elif args.black_mat:
    black_color = get_color_for_material(args.black_mat)
    if not black_color:
      ap.error(f"Invalid or unknown material {args.black_mat!r}")

  jobs = [dict(
    runner=runner,
    path=fimg,
    threshold=args.threshold,
    size=size_arg,
    outpath=args.outpath,
    white=white_color,
    black=black_color,
    regenerate=args.regenerate,
  ) for fimg in frames]
  for _ in pool.starmap(downsample_one_runner, [(job, queue) for job in jobs]):
    pass

  pool.close()
  pool.join()
  monitor.join()

if __name__ == "__main__":
  main()

# vim: set ts=2 sts=2 sw=2:
