-- Copyright (c) 2024 petzku <petzku@zku.fi>

main = (sub, sel) ->
    for i in *sel
        line = sub[i]
        continue unless line.text\match "\\p1"
        tags = line.text\match "%b{}"
        shape = line.text\sub #tags + 1
        sub.delete i
        for sh in shape\gmatch "m [^m]+"
            line.text = tags .. sh
            sub[-i] = line

aegisub.register_macro "Split shapes", "Split shapes into multiple events on each m-command", main