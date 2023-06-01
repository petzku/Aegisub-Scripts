color = require '0x.color'

-- edit this
DISTANCE = 2

ext = (sub, sel, dist) ->
    a = sub[sel[1]]
    b = sub[sel[2]]

    c1 = a.text\match "\\c(&H......&)"
    c2 = b.text\match "\\c(&H......&)"

    c3 = color.interp_lch dist, c1, c2

    n = b
    n.text = n.text\gsub "\\c(&H......)", "\\c#{c3}"

    sub[-(sel[2] + 1)] = n

main = (sub, sel) -> ext sub, sel, DISTANCE
gui = (sub, sel) ->
    res, btn = aegisub.dialog.display {
        {class: "label", text: "distance to extrapolate to"},
        {class: "floatedit", name: t, value: 2, hint: "0 = start, 1 = end. useful values will be outside this range"}
    }
    ext sub, sel, res.t if btn

aegisub.register_macro "extrapolate color", "", main
aegisub.register_macro "extrapolate color gui", "", gui
