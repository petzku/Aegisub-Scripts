color = require '0x.color'

-- edit this
DISTANCE = 2

main = (sub, sel) ->
    a = sub[sel[1]]
    b = sub[sel[2]]

    c1 = a.text\match "\\c(&H......&)"
    c2 = b.text\match "\\c(&H......&)"

    c3 = color.interp_lch DISTANCE, c1, c2

    n = b
    n.text = n.text\gsub "\\c(&H......)", "\\c#{c3}"

    sub[-(sel[2] + 1)] = n

aegisub.register_macro "extrapolate color", "", main
