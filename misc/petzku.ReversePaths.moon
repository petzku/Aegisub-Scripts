-- Copyright (c) 2024, petzku <petzku@zku.fi>

export script_name =        "Reverse Paths"
export script_description = "Reverse winding direction of all paths in a drawing (or clip)"
export script_author =      "petzku"
export script_namespace =   "petzku.ReversePaths"
export script_version =     "0.1.0"

COORD = "[-+]?[%d.]+"
ONE_POINT = "(#{COORD}) (#{COORD})"
THREE_POINT = "#{ONE_POINT} #{ONE_POINT} #{ONE_POINT}"

print = (...) -> aegisub.log table.concat({...}, "\t" .. "\n")

parse_segment = (part) ->
    segs = {}
    -- drawing command type. defaults to m Just In Case
    -- code only supports mbl because lazy; might improve later
    cmd = "m"
    i = 1
    -- store previous segment's end coords on every segment. necessary to reverse beziers correctly.
    -- unnecessary for anything else; we will discard them in format_segment anyway
    local px, py
    while i < #part
        -- try to get new drawing command. skip whitespace until finding this
        curr = part\match "%S", i
        if curr\match "[mbl]"
            cmd = curr
            -- set new lookhead to after the command
            i = 1 + part\find "%S", i
            continue
        -- no new drawing command -> continue normally
        local points, match_end
        if cmd == "b"
            _, match_end, x, y, xx, yy, xxx, yyy = part\find THREE_POINT, i
            points = {{px, py}, {x, y}, {xx, yy}, {xxx, yyy}}
            px, py = xxx, yyy
        else
            -- some other command
            _, match_end, x, y = part\find ONE_POINT, i
            if cmd == "m"
                -- technically unnecessary, as parse_segment should only ever get single-m shapes
                -- but doing this is important if that fact ever changes
                points = {{x, y}, {x, y}}
            else
                points = {{px, py}, {x, y}}
            px, py = x, y
        break unless match_end
        -- update lookhead
        i = match_end + 1
        table.insert segs, {:cmd, :points}
    -- finally, implicit closing line from final point to origin
    org = segs[1].points[1]
    table.insert segs, {cmd: "l", points: {{px, py}, org}}
    segs

reverse_segment = (arcs) ->
    new = {arcs[1]}
    for i = #arcs, 2, -1
        arc = arcs[i]
        if arc.cmd == "b"
            arc.points = {arc.points[4], arc.points[3], arc.points[2], arc.points[1]}
        else
            arc.points = {arc.points[2], arc.points[1]}
        table.insert new, arc
    new

format_segment = (arcs) ->
    res = {}
    prev = nil
    for arc in *arcs
        table.insert res, arc.cmd unless arc.cmd == prev
        -- ignore the first (origin) point of each segment
        for i = 2, #arc.points
            table.insert res, table.concat arc.points[i], " "
        prev = arc.cmd
    table.concat res, " "

reverse = (drawing) ->
    res = {}
    for part in drawing\gmatch "m[^m]+"
        table.insert res, format_segment reverse_segment parse_segment part
    table.concat res, " "

main = (sub, sel) ->
    for i in *sel
        line = sub[i]
        if line.text\match "\\clip%(m"
            clipstart, clipend = line.text\find "\\clip%b()"
            clip = line.text\sub clipstart + 6, clipend - 1
            new = reverse clip
            line.text = line.text\sub(1, clipstart + 5) .. new .. line.text\sub(clipend)
            sub[i] = line
        elseif line.text\match "\\p"
            tagstart, tagend = line.text\find "%{.*%}"
            draw = line.text\sub tagend + 1
            new = reverse draw
            line.text = line.text\sub(tagstart, tagend) .. new
            sub[i] = line


aegisub.register_macro script_name, script_description, main