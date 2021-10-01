-- Groups/sorts lines by colour tags.
--
-- Initial version just groups by \1c.
-- Later versions should be able to e.g. sort by colour components, and choose which tag(s) to sort by.

script_name        = "Sort by Colour"
script_description = "Sort and/or group lines by colour tags"
script_author      = "petzku"
script_namespace   = "petzku.ColourSort"
script_version     = "0.1"

require 'karaskel'

add_to = (t, line, index) ->
    if not t[index]
        t[index] = {}
    table.insert t[index], line

can_run = (subs, sel, _) ->
    #sel > 1

main = (subs, sel, _) ->
    -- we assume selection will be contiguous; it might work otherwise too but no guarantees
    meta, styles = karaskel.collect_head subs, false

    aegisub.log 5, "subs len before del: %d\n", #subs

    lines = {}
    for i in *sel
        line = subs[i]
        karaskel.preproc_line subs, meta, styles, line
        c = line.text\match("\\1?c[H&]*([0-9A-Fa-f]+)") or line.styleref.color1\sub(5,-2) --style default colour if line has no tag
        add_to lines, line, c

    for i = #sel, 1, -1
        aegisub.log 5, "delete: %d of %d\n", i, #subs
        subs.delete sel[i]

    aegisub.log 5, "subs len after del: %d\n", #subs

    i = 1
    for c,grp in pairs lines
        for line in *grp
            subs.insert i, line
            aegisub.log 5, "inserting [%d], %s\n", i, line.text
            i += 1

    aegisub.set_undo_point "group lines by fill colour"

aegisub.register_macro script_name, script_description, main, can_run
