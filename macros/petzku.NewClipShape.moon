-- Copyright (c) 2021 petzku <petzku@zku.fi>

export script_name =        "New Clip Shape"
export script_description = "Converts the last point of a vectorial clip into a new origin point"
export script_author =      "petzku"
export script_namespace =   "petzku.NewClipShape"
export script_version =     "0.1.0"

havedc, DependencyControl, dep = pcall require, "l0.DependencyControl"
if havedc
    dep = DependencyControl{}

way_overcomplicated = (clip) ->
    local last_points, last_start, last_end
    -- cmd = clip\sub(1,1) --should always be m
    -- clip = clip\sub(2)

    aegisub.log 4, "way_overcomplicated(%s)\n", clip
    orig_clip = clip

    while true
        i = clip\find("[mlb]")

        unless i break
        cmd = clip\sub(i,i)
        clip = clip\sub(i+1)

        aegisub.log 4, "drawing command: %s, remaining: %s\n", cmd, clip

        pattern = if cmd == "b"
                " [-%d.]+ [-%d.]+ [-%d.]+ [-%d.]+ [-%d.]+ [-%d.]+"
        else
                " [-%d.]+ [-%d.]+"

        stringpos = 0
        while true
            pi, pj = clip\find(pattern, stringpos+1)
            unless pi break
            last_points = clip\sub(pi,pj)
            last_start, last_end = pi, pj
            stringpos = pj + 1

            aegisub.log 4, "points: %s (idx %d-%d), remaining: %s\n", last_points, pi, pj, clip\sub(last_end+1)

    if temp = last_points\match(" [-%d.]+ [-%d.]+ [-%d.]+ [-%d.]+ ([-%d.]+ [-%d.]+)")
        last_points = temp

    new_clip = clip\sub(1, last_start-1).." m" .. last_points
    return new_clip

simpler = (clip) ->
    aegisub.log 4, "simpler(%s)\n", clip

    clip\gsub(" ([-%d.]+ [-%d.]+)%s*$", " m %1")

make_final_move = simpler

main = (subs, sel) ->
    for i in *sel
        line = subs[i]

        aegisub.log 5, "looking at line %d: %s\n", i, line.text
        -- other drawing commands exist, but I'm only concerned with the ones aegisub supports currently
        clip = line.text\match("\\i?clip%((%s*m%s+[%s%-%d.mlb]+)%)")
        unless clip continue

        newclip = make_final_move(clip)

        aegisub.log 5, "got back: %s\n", newclip

        line.text = line.text\gsub(clip, newclip, 1)

        aegisub.log 5, "after gsub, line.text: %s\n", line.text

        subs[i] = line

can_run = (subs, sel) ->
    for i in *sel
        line = subs[i]
        if line.text\match "\\i?clip%(m .*%)"
            return true
    return false

if havedc
    dep\registerMacro main, can_run
else
    aegisub.register_macro(script_name, script_description, main, can_run)
