-- Copyright (c) 2022 petzku <petzku@zku.fi>

export script_name =        "Noter"
export script_description = "Add a 'note' comment block at the end of the current line"
export script_author =      "petzku"
export script_namespace =   "petzku.Noter"
export script_version =     "0.1.0"

add_note = (line, pre, post) ->
    line.text ..= "{#{pre}#{post}}"
    line

main = (sub, _, act) ->
    sub[act] = add_note sub[act], "", " -p"

aegisub.register_macro script_name, script_description, main
