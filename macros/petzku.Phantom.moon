-- Copyright (c) 2022, petzku <petzku@zku.fi>

export script_name =        "Phantom"
export script_description = "Align line content to match others by adding text and abusing transparency"
export script_author =      "petzku"
export script_namespace =   "petzku.Phantom"
export script_version =     "0.2.0"

-- Currently uses {} as delimiters
-- e.g. "foo{}bar{}baz" -> "<HIDE>bar<SHOW>foobar<HIDE>baz"

-- TODO:
-- - refactor to make things nicer
-- - use cursor manipulation from arch1t3ct if possible

HIDE = "{\\alpha&HFF&}"
SHOW = "{\\alpha}"

-- only operate on active line; ignore selection
main = (sub, act, rep) ->
    line = sub[act]
    
    -- extract start tags
    start, text = line.text\match "^({.-})(.+)$"
    unless start
        start, text = "", line.text

    procd = {}

    for part in string.gmatch text.."\\N", "(.-)\\N"
        -- thanks for the Universal Pattern Hammer, arch1t3ct
        part = part\gsub "^(.-){}(.-){}(.-)$", rep
        table.insert procd, part
    
    line.text = start .. table.concat procd, "\\N"
    sub[act] = line

align_start = (sub, _sel, act) ->
    rep = (beg, mid, den) -> HIDE..mid..SHOW..beg..mid..HIDE..den
    main sub, act, rep

align_end = (sub, _sel, act) ->
    rep = (beg, mid, den) -> HIDE..beg..SHOW..mid..den..HIDE..mid
    main sub, act, rep

aegisub.register_macro script_name.."/Align start", "Keep start of line aligned", align_start
aegisub.register_macro script_name.."/Align end", "Keep end of line aligned", align_end
