export script_name =        "RecalColor"
export script_description = "Like Recalculator, but worse and for color tags"
export script_author =      "petzku"
export script_namespace =   "petzku.RecalColor"
export script_version =     "0.2.0"


GUI = {
    { x: 0, y: 0, class: 'checkbox', label: "Primary (\\&1c)", value: false, name: 'c1', hint: "Apply to fill color" },
    { x: 1, y: 0, class: 'checkbox', label: "Karaoke (\\&2c)", value: false, name: 'c2', hint: "Apply to karaoke fill color" },
    { x: 2, y: 0, class: 'checkbox', label: "Border (\\&3c)", value: false, name: 'c3', hint: "Apply to border color" },
    { x: 3, y: 0, class: 'checkbox', label: "Shadow (\\&4c)", value: false, name: 'c4', hint: "Apply to shadow color" },

    { x: 0, y: 1, class: 'label', label: "&Hue" },
    { x: 1, y: 1, class: 'floatedit', value: 0, min: -360, max: 360, name: 'hue', hint: "How much to add/remove to hue" },
    { x: 0, y: 2, class: 'label', label: "&Saturation" },
    { x: 1, y: 2, class: 'floatedit', value: 0, min: -1, max: 1, name: 'sat', hint: "How much to add/remove to saturation" },
    { x: 0, y: 3, class: 'label', label: "&Lightness" },
    { x: 1, y: 3, class: 'floatedit', value: 0, min: -1, max: 1, name: 'light', hint: "How much to add/remove to lightness" },
}

util = require 'aegisub.util'
ln = require 'ln.kara'
-- KaraOK uses this without the 'util' prexix, because karaskel does weird stuff.
-- Export it manually, else the functions don't work.
export extract_color = util.extract_color

make_adjust = (hue, sat, light) ->
    h = hue / 360 * 255
    s = sat * 255
    l = light * 255
    aegisub.log 5, "adding %s, %s, %s to colors\n", h,s,l
    (color) -> ln.color.byHSL ln.color.hsl.add color, h,s,l

main = (sub, sel) ->
    btn, res = aegisub.dialog.display GUI
    if btn
        fun = make_adjust res.hue, res.sat, res.light
        tag_replace = (str) ->
            aegisub.log 5, "editing tag '%s'\n", str
            str\gsub "&H......&", fun

        -- todo: take input from dialog
        pattern = "\\["
        pattern ..= "1" if res.c1
        pattern ..= "2" if res.c2
        pattern ..= "3" if res.c3
        pattern ..= "4" if res.c4
        pattern ..= "]"
        pattern ..= "?" if res.c1
        pattern ..= "c&H......&"
        aegisub.log 5, "using pattern '%s'\n", pattern
        for i in *sel
            line = sub[i]
            line.text = line.text\gsub pattern, tag_replace
            sub[i] = line

aegisub.register_macro script_name, script_description, main
