-- Copyright (c) 2024 petzku <petzku@zku.fi>

export script_name =        "Interpolate Clip"
export script_description = "Interpolate vectorial clip from A to B, assuming equal commands and points"
export script_author =      "petzku"
export script_namespace =   "petzku.InterClip"
export script_version =     "0.0.1"


-- ILL probably does this a lot better, use that instead.


log = require "petzku.log"


clip_stt = (clip) ->
    t = {}
    -- this will break if the first point doesn't have a command. i don't care
    for cmd, x, y in clip\gmatch "([a-z]?)%s*([+-]?[%d.]+) ([+-]?[%d.]+)"
        local tt
        if cmd != ""
            tt = {:cmd, pts: {}}
            table.insert t, tt
        else
            tt = t[#t]
        table.insert tt.pts, x
        table.insert tt.pts, y
    t

flatten = (t) ->
    flat = {}
    for tt in *t
        table.insert flat, tt.cmd
        for p in *tt.pts
            table.insert flat, p
    flat

clip_tts = (t) ->
    table.concat t, " "

check_clips = (a, b) ->
    -- check that the clips have equal commands and point counts
    return false unless #a == #b
    for i=1,#a
        aa = a[i]
        bb = b[i]
        return false unless aa.cmd == bb.cmd and #aa.pts == #bb.pts
    true


main = (sub, sel) ->
    unless #sel > 2
        log.error "Select at least three lines!"
        aegisub.cancel!
        return
    first = sub[sel[1]]
    last = sub[sel[#sel]]

    fclip = first.text\match "\\i?clip(%b())"
    lclip = last.text\match "\\i?clip(%b())"
    unless fclip and lclip
        log.error "Missing clip(s)!"
        aegisub.cancel!
        return

    are_vect = not (fclip\find(",") or lclip\find(","))
    unless are_vect
        log.error "Clips should be vectorial!"
        aegisub.cancel!
        return

    st = clip_stt fclip
    en = clip_stt lclip

    log.trace "parsed %s into %s", fclip, clip_tts flatten st
    log.trace "parsed %s into %s", lclip, clip_tts flatten en

    unless check_clips st, en
        log.error "Clips must have matching commands and points!"
        aegisub.cancel!
        return

    fflat = flatten st
    lflat = flatten en

    -- skip first and last lines (those are already by definition correct)
    for i = 2, #sel-1
        li = sel[i]
        line = sub[li]
        t = (i - 1) / (#sel - 1)
        flat = {}
        for j = 1, #fflat
            if fflat[j] == lflat[j]
                table.insert flat, fflat[j]
            else
                -- interp = (1-t) * a + t * b == a + t * (b-a)
                a = fflat[j]
                b = lflat[j]
                new = a + t * (b - a)
                log.trace "interpolated %s\t at %f\t from %s\t to %s", new, t, a, b
                table.insert flat, new
        line.text = line.text\gsub "(\\i?clip)%b()", "%1(#{clip_tts flat})"
        sub[li] = line

aegisub.register_macro script_name, script_description, main
