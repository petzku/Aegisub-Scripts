# petzku's Aegisub scripts

Automation scripts for Aegisub. These are probably mostly useful for typesetters, if anyone.

## Required modules

### DependencyControl

Scripts I make will use [DependencyControl](https://github.com/TypesettingTools/DependencyControl) for versioning and dependency management.

## Scripts

### Accenter

Adds diacritics (accents) to lines based on inline comments. Sometimes you want to use glyphs that don't exist in a font, but don't want to or can't edit the font. So you add lines with the shapes you want. But maybe you don't want to position them manually, or maybe the script isn't final yet so you can't. Enter Accenter. Fairly simple instructions given before a character get turned into a line with a diacritic at the character's position.

For example, the line

```ass
Te{!aˇ}st li{\c&H6C42F7&}{!amacron}{!a+10grave}ne as{!b`}d{\c&H1C9C3A&\3c&HEBEBEB&}f{!b+5˘}h
```

turns into this (with ASS garbage stripped out):

```ass
Te{!aˇ}st li{\c&H6C42F7&}{!amacron}{!a+10grave}ne as{!b`}d{\c&H1C9C3A&\3c&HEBEBEB&}f{!b+5˘}h
{\pos(826.02,995.00)\an5}ˇ
{\pos(940.20,995.00)\an5\c&H6C42F7&}ˉ
{\pos(940.20,985.00)\an5\c&H6C42F7&}`
{\pos(1091.08,1051.52)\an5\c&H6C42F7&}`
{\pos(1154.54,1046.52)\an5\c&H6C42F7&\c&H1C9C3A&\3c&HEBEBEB&}˘
```

And here's how it looks:

![accenter.png](accenter.png)

The script creates the lines with `accent` in the effect field, so they're easy to remove, and get automatically cleaned up when running it again. The marker tag blocks are also left intact.

The full syntax for this can be found in the script's README comments. I do not guarantee backwards compatibility before 1.0, in fact I'm currently considering alternatives for the `a`/`b` labels for above/below.

### Clip Size

Tells you the distances between points in a vector clip on the selected line. The utility of this is debatable, but I find it useful to quickly compare sizes of similar signs or text in different parts of the video.

### Extrapolate Move

Takes a line with a partial-duration move and extends it to the line's full duration. For instance, a line with duration of 3000 ms and a movement of `\move(320,200,520,100,1000,2000)` would end up with `\move(120,300,720,0)`. Useful for doing linear movements when you can't align the start and/or end points with traditional means (maybe because they're offscreen).

### Jump to Next++

Adds a mode to unanimated's [Jump to Next](https://github.com/unanimated/luaegisub/blob/master/ua.JumpToNext.lua) script, allowing you to jump by lines' start and end times. The script should work standalone too, if these are the only features you want out of it.

### Typewriter

Takes a line and "writes" it character by character, making the characters appear one by one (using alphas) either frame-by-frame or evenly spaced over the line's duration. My first script, initially made before I even knew what the hell alpha-timing was and actually deleted characters from the string to make this work. Obviously this has been changed since.

Currently does not play well with `\move` or `\t` tags. There's a good chance another script does what this one does already, except better. Might also eventually implement right-to-left and/or bottom-to-top writing.
