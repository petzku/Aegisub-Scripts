import sys
import xml.etree.ElementTree as ET

if len(sys.argv) > 1:
    FILENAME = sys.argv[1]
else:
    FILENAME = "chapters.xml"

# read XML

tree = ET.parse(FILENAME)
root: ET.Element = tree.getroot()
chapters = []

for edition in root.iter("EditionEntry"):
    for ch in edition.iter("ChapterAtom"):
        name = ch.find("ChapterDisplay").find("ChapterString").text
        ustime = ch.find("ChapterTimeStart").text

        # time is in hh:mm:ss.us format. convert to h:mm:ss.cs for ASS

        cstime = ustime[1:-7]

        chapters.append((name, cstime))

# write ASS. be lazy and don't worry too much about headers -- i'm pretty sure aegisub can open even extremely cursed files

if len(sys.argv) > 2:
    OUTNAME = sys.argv[2]
else:
    OUTNAME = "chapters.ass"

with open(OUTNAME, "w") as fo:
    fo.write("[Script Info]\n")
    fo.write("[Events]\n")
    fo.write(
        "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n"
    )

    template = "Comment: 0,{time},{time},Default,chapter,0,0,0,,{{{name}}}\n"
    fo.writelines(template.format(time=time, name=name) for name, time in chapters)
