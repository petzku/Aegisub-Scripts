-- Copyright (c) 2022 petzku <petzku@zku.fi>

export script_name =        "Noter"
export script_description = "Add a 'note' comment block at the end of the current line"
export script_author =      "petzku"
export script_namespace =   "petzku.Noter"
export script_version =     "0.2.0"

-- TODO: arbitrary pre/postfix support
PRE = ""
POST = " -p"

add_note = (line, pre, post, idx = #line.text+1) ->
    beg, den = line.text\sub(1, idx-1), line.text\sub(idx)
    line.text = beg .. "{#{pre}#{post}}" .. den
    if aegisub.gui and aegisub.gui.set_cursor
        aegisub.gui.set_cursor idx + 1 + #pre
    line

main = (sub, _, act) ->
    sub[act] = add_note sub[act], PRE, POST
    
at_cursor = (sub, _, act) ->
    sub[act] = add_note sub[act], PRE, POST, aegisub.gui.get_cursor!


if aegisub.gui and aegisub.gui.get_cursor
    aegisub.register_macro script_name, script_description, at_cursor
else
    aegisub.register_macro script_name, script_description, main
