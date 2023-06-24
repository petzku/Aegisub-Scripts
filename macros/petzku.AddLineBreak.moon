-- Copyright (c) 2023 petzku <petzku@zku.fi>

export script_name =        "Add line break at cursor"
export script_description = "Add line break at cursor position, plus a \\q2 at line start if not present"
export script_author =      "petzku"
export script_namespace =   "petzku.AddLineBreak"
export script_version =     "0.2.0"


main = (sub, _sel, act) ->
    line = sub[act]

    idx = aegisub.gui.get_cursor!
    beg, den = line.text\sub(1, idx-1), line.text\sub(idx)

    line.text = beg .. "\\N" .. den

    offset = 2
    -- add a \q2 if necessary at start; checking is somewhat lazy
    unless line.text\match "\\q2"
        if line.text\match "^%b{}"
            line.text = "{\\q2" .. line.text\sub 2
            offset += 3
        else
            line.text = "{\\q2}" .. line.text
            offset += 5
    aegisub.gui.set_cursor idx + offset
    sub[act] = line

-- only register if the required function actually exists
if aegisub.gui and aegisub.gui.get_cursor
    aegisub.register_macro script_name, script_description, main
