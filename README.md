# petzku's Aegisub scripts

Automation scripts for Aegisub. These are probably mostly useful for typesetters, if anyone.

## Required modules

### DependencyControl

Scripts I make will use [DependencyControl](https://github.com/TypesettingTools/DependencyControl) for versioning and dependency management.

## Scripts

### ClipSize

Tells you the distances between points in a vector clip on the selected line. The utility of this is debatable, but I find it useful to quickly compare sizes of similar signs or text in different parts of the video.

### ExtrapolateMove

Takes a line with a partial-duration move and extends it to the line's full duration. For instance, a line with duration of 3000 ms and a movement of `\move(320,200,520,100,1000,2000)` would end up with `\move(120,300,720,0)`. Useful for doing linear movements when you can't align the start and/or end points with traditional means (maybe because they're offscreen).
