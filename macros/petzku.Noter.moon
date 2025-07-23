-- Copyright (c) 2022 petzku <petzku@zku.fi>

export script_name =        "Noter"
export script_description = "Add a 'note' comment block at the end of the current line"
export script_author =      "petzku"
export script_namespace =   "petzku.Noter"
export script_version =     "0.4.0"

-- TODO: arbitrary pre/postfix support
PRE = "@ED "
POST = " -p"

MARKERS = {"ED", "TM", "TLC", "TS", "ST", "QC"}

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

_iof = (k) ->
    for i, v in ipairs MARKERS
        if v == k then return i
    return 0

cycle_marker = (sub, sel) ->
    for i in *sel
        line = sub[i]
        line.effect = MARKERS[(_iof(line.effect) % #MARKERS) + 1]
        sub[i] = line

copy_marker = (sub, sel) ->
    -- Copy any @'s from the line into the effect field
    -- If none present, call cycle_marker instead
    for i in *sel
        line = sub[i]
        pings = {}
        for p in line.text\gmatch "[@/]([A-Z]+)"
            table.insert(pings, p)
        if #pings == 0
            cycle_marker sub, sel
        else
            -- filter out duplicates—this is kinda hacky
            t = {}
            for p in *pings
                t[p] = p
            pings = {}
            for k, _ in pairs t
                table.insert(pings, k)
            line.effect = table.concat(pings, '/')
            sub[i] = line

if aegisub.gui and aegisub.gui.get_cursor
    aegisub.register_macro "#{script_name}/Add note", script_description, at_cursor
else
    aegisub.register_macro "#{script_name}/Add note", script_description, main
aegisub.register_macro "#{script_name}/Cycle marker", "Cycle ED/TM/TS/... effect marker for selected lines", cycle_marker
aegisub.register_macro "#{script_name}/Add marker", "Copy marker from inline @'s into effect, or cycle if none present", copy_marker
