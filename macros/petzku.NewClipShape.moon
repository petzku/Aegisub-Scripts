-- Copyright (c) 2021 petzku <petzku@zku.fi>

export script_name =        "New Clip Shape"
export script_description = "Converts the last point of a vectorial clip into a new origin point"
export script_author =      "petzku"
export script_namespace =   "petzku.NewClipShape"
export script_version =     "0.1.0"

havedc, DependencyControl, dep = pcall require, "l0.DependencyControl"
if havedc
    dep = DependencyControl{}

make_final_move = (clip) ->
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

        newclip = make_final_move clip

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
