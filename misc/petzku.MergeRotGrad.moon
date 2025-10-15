-- tags to compare equality for
TAGS = {"\\c&"}

is_same = (t, cur) ->
    for k in *TAGS
        return false if t[k] != cur.text\match "#{k}[^\\}]+"
    true

log = (s="", ...) -> aegisub.log 5, "#{s}\n", ...

main = (sub, sel) ->
    si = #sel
    while si > 0
        if aegisub.progress.is_cancelled!
            aegisub.cancel!
            return
        first = sub[sel[si]]

        -- copy tag set
        t = {}
        for k in *TAGS
            t[k] = first.text\match "#{k}[^\\}]+"
        vect1 = first.text\match "\\i?clip(%b())"
        log "vect1: %s", vect1
        _x1, _y1, _x2, _y2, x3, y3, x4, y4 = vect1\match("m (-?[%d.]+) (-?[%d.]+) l (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+)")

        log "si: %d, i: %d", si, sel[si]
        log "t:"
        log "  %s - %s", k, v for k,v in pairs t

        did_merge = false
        while si - 1 > 0
            j = sel[si - 1]
            log "j: %d", j
            cur = sub[j]
            if is_same t, cur
                -- remove previous line, decrement si (now cur is "first")
                sub.delete sel[si]
                si -= 1
                did_merge = true
            else
                -- not same. break out of loop, then merge stuff
                break
        if did_merge
            cur = sub[sel[si]]
            -- now, replace the tag in 'cur' with the proper thing
            vect2 = cur.text\match "\\i?clip(%b())"
            x1, y1, x2, y2, _x3, _y3, _x4, _y4 = vect2\match("m (-?[%d.]+) (-?[%d.]+) l (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+) (-?[%d.]+)")

            vect = "(m #{x1} #{y1} l #{x2} #{y2} #{x3} #{y3} #{x4} #{y4})"
            cur.text = cur.text\gsub "(\\i?clip)%b()", (tag) -> tag..vect

            log "vect2: %s", vect2
            log "vect: %s", vect


            sub[sel[si]] = cur
        si -= 1

aegisub.register_macro "merge rotated gradients", "", main
