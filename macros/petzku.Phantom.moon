-- Copyright (c) 2022, petzku <petzku@zku.fi>

export script_name =        "Phantom"
export script_description = "Align line content to match others by adding text and abusing transparency"
export script_author =      "petzku"
export script_namespace =   "petzku.Phantom"
export script_version =     "0.1.0"

-- Currently uses {} as delimiters
-- e.g. "foo{}bar{}baz" -> "<HIDE>bar<SHOW>foobar<HIDE>baz"

-- TODO:
-- - refactor to make things nicer
-- - support shifting left and right
-- - use cursor manipulation from arch1t3ct if possible

HIDE = "{\\alpha&HFF&}"
SHOW = "{\\alpha}"

-- only operate on active line; ignore selection
main = (sub, _sel, act) ->
    line = sub[act]
    
    -- extract start tags
    start, text = line.text\match "^({.-})(.+)$"
    unless start
        start, text = "", line.text

    procd = {}

    text = [part for part in (text.."\\N")\gmatch "(.-)\\N"]
    for part in *text
        if i = part\find "{}"
            -- *maybe* there's a way to do this more cleanly
            if j = part\find "{}", i+1
                beg = part\sub 1, i-1       -- untouched
                mid = part\sub i+2, j-1     -- keep this where it is; clone to start hidden
                den = part\sub j+2          -- keep this at the end; hide

                part = HIDE..mid..SHOW..beg..mid..HIDE..den
        table.insert procd, part
    
    line.text = start .. table.concat procd, "\\N"
    sub[act] = line

aegisub.register_macro script_name, script_description, main
