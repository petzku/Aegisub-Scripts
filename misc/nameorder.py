# complement to petzku.NameOrder.moon, but works outside aegisub
# could use libraries for reading ASS files, but it's simple enough to do manually

import sys
from pathlib import Path

fpath: str | Path

NAMES = [
    "Kurokawa Akane",
    "Hoshino Aqua",
    "Hoshino Ruby",
    "Arima Kana",
]
reversed = [" ".join(n.split()[::-1]) for n in NAMES]

if len(sys.argv) > 1:
    fpath = sys.argv[1]
else:
    # if called without filename, assume the latest glob match for "*dialogue*.ass" in current directory
    # "ialogue" to be case insensitive
    fpath = max(Path("./").glob("*ialogue*.ass"))

with open(fpath, "r") as fo:
    lines = fo.readlines()

edited = False

for i, line in enumerate(lines):
    if not line.startswith("Dialogue:"):
        continue
    cont = line.split(",", 10)
    text = cont[-1]
    if any(name in text for name in reversed):
        # found bad name, flag and move on
        cont[-2] += "!! WRONG NAME ORDER !!"
        lines[i] = ",".join(cont)
        # output to terminal too
        print(f"Bad line at {cont[1]}-{cont[2]}: {text}")
        edited = True

if edited:
    with open(fpath, "w") as fo:
        fo.writelines(lines)
