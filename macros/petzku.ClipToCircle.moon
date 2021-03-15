-- Copyright (c) 2021 petzku <petzku@zku.fi>

export script_name =        "Clip to Circle"
export script_description = "Create a bezier-approximation of a circle based on a clip"
export script_author =      "petzku"
export script_namespace =   "petzku.ClipToCircle"
export script_version =     "1.0.0"

create_circle = (r) ->
    -- https://stackoverflow.com/a/27863181
    -- f = 0.552284749831   -- maximum drift 0.027253 %, minimum drift 0 %
    -- f = 0.55191502449    -- maximum and minimum drift ±0.019608 %
    f = 0.552       -- maximum drift 0.021212 %, minimum drift -0.015101 %
    string.format "m %.2f 0 b %.2f %.2f %.2f %.2f %.2f %.2f b %.2f %.2f %.2f %.2f %.2f %.2f b %.2f %.2f %.2f %.2f %.2f %.2f b %.2f %.2f %.2f %.2f %.2f %.2f",
        r, -- 0
        r, f*r,   f*r, r,   0, r,
        -f*r, r,  -r, f*r,  -r, 0,
        -r, -f*r, -f*r, -r, 0, -r,
        f*r, -r,  r, -f*r,  r, 0

main = (subs, sel) ->
    for i in *sel
        line = subs[i]
        clip = line.text\match('\\i?clip(%b())')
        unless clip continue

        x, y, tx, ty = clip\match("(-?[%d.]+) (-?[%d.]+) . (-?[%d.]+) (-?[%d.]+)")
        r = math.sqrt((tx-x)*(tx-x) + (ty-y)*(ty-y))
        circle = create_circle(r)

        line.text = string.format "{\\an7\\pos(%.2f,%.2f)\\p1}%s", x, y, circle
        subs[i] = line

aegisub.register_macro script_name, script_description, main
