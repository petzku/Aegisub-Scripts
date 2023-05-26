-- Copyright (c) 2023, petzku <petzku@zku.fi>

export script_name = "Merge Vector Clip"
export script_description = "Copy vector clip from first line and merge onto rest in selection"
export script_author = "petzku"
export script_namespace = "petzku.MergeVectClip"
export script_version = "0.2.0"


main_all = (sub, sel) ->
    first = sub[sel[1]]
    -- extract clip from first line
    mainclip = first.text\match("\\i?clip(%b())")\match("%b()")\sub(2, -2)
    for si = 2, #sel
        i = sel[si]
        line = sub[i]
        line.text = line.text\gsub "(\\i?clip)(%b())", (tag, cont) ->
            "#{tag}(#{mainclip} #{cont\sub(2, -2)})"
        sub[i] = line

main_pairwise = (sub, sel) ->
    for si = 1, #sel, 2
        ia = sel[si]
        ib = sel[si+1]
        first = sub[ia]
        second = sub[ib]
        mainclip = first.text\match("\\i?clip(%b())")\match("%b()")\sub(2, -2)
        second.text = second.text\gsub "(\\i?clip)(%b())", (tag, cont) ->
            "#{tag}(#{mainclip} #{cont\sub(2, -2)})"
        first.effect ..= " delete"
        sub[ia] = first
        sub[ib] = second


canrun_all = (sub, sel) ->
    return false unless #sel > 1
    for i in *sel
        return false unless sub[i].text\match "clip"
    return true

canrun_pairwise = (sub, sel) ->
    return false unless #sel % 2 == 0
    for i in *sel
        return false unless sub[i].text\match "clip"
    return true


aegisub.register_macro "#{script_name}/From first", script_description, main_all, canrun_all
aegisub.register_macro "#{script_name}/Pairwise", script_description, main_pairwise, canrun_pairwise
