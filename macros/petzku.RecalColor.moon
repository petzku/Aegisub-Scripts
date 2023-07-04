export script_name =        "RecalColor"
export script_description = "Like Recalculator, but worse and for color tags"
export script_author =      "petzku"
export script_namespace =   "petzku.RecalColor"
export script_version =     "0.4.0"


GUI = {
    { x: 0, y: 0, class: 'label', label: "Change color values by:" },
    -- value settings
    { x: 0, y: 1, class: 'label', label: "&Hue" },
    { x: 1, y: 1, class: 'floatedit', value: 0, min: -360, max: 360, name: 'hue', hint: "How much to add/remove to hue" },
    { x: 0, y: 2, class: 'label', label: "&Saturation" },
    { x: 1, y: 2, class: 'floatedit', value: 0, min: -1, max: 1, name: 'sat', hint: "How much to add/remove to saturation" },
    { x: 0, y: 3, class: 'label', label: "&Lightness" },
    { x: 1, y: 3, class: 'floatedit', value: 0, min: -1, max: 1, name: 'light', hint: "How much to add/remove to lightness" },
    { x: 0, y: 4, class: 'label', label: "&Alpha" },
    { x: 1, y: 4, class: 'floatedit', value: 0, min: -255, max: 255, name: 'alpha', hint: "How much to add/remove to alpha" },

    -- tag selection. alpha is first here so tab focuses it from the alpha value input box. this is a terrible hack and should probably not be done
    { x: 2, y: 4, class: 'checkbox', label: "Line alpha (\\alpha)", value: false, name: 'full', hint: "Apply to whole line (alpha only)" },
    { x: 2, y: 0, class: 'checkbox', label: "Primary (\\&1c)", value: false, name: 'c1', hint: "Apply to fill color" },
    { x: 2, y: 1, class: 'checkbox', label: "Karaoke (\\&2c)", value: false, name: 'c2', hint: "Apply to karaoke fill color" },
    { x: 2, y: 2, class: 'checkbox', label: "Border (\\&3c)", value: false, name: 'c3', hint: "Apply to border color" },
    { x: 2, y: 3, class: 'checkbox', label: "Shadow (\\&4c)", value: false, name: 'c4', hint: "Apply to shadow color" },
}

util = require 'aegisub.util'
ln = require 'ln.kara'
-- KaraOK uses this without the 'util' prexix, because karaskel does weird stuff.
-- Export it manually, else the functions don't work.
export extract_color = util.extract_color

make_adjust_color = (hue, sat, light) ->
    h = hue / 360 * 255
    s = sat * 255
    l = light * 255
    aegisub.log 5, "adding %s, %s, %s to colors\n", h,s,l
    (color) -> ln.color.byHSL ln.color.hsl.add color, h,s,l

make_adjust_alpha = (delta) -> (tagval) ->
    _,_,_,a = util.extract_color tagval
    util.ass_alpha ln.math.clamp a + delta, 0, 255

make_base_pattern = (res, tagpart) ->
    pattern = "\\["
    pattern ..= "1" if res.c1
    pattern ..= "2" if res.c2
    pattern ..= "3" if res.c3
    pattern ..= "4" if res.c4
    pattern ..= "]"
    pattern ..= "?" if res.c1 and tagpart\sub(1,1) == "c"
    pattern .. tagpart

main = (sub, sel) ->
    btn, res = aegisub.dialog.display GUI
    if btn
        cfun = make_adjust_color res.hue, res.sat, res.light
        afun = make_adjust_alpha res.alpha
        color_replace = (str) ->
            aegisub.log 5, "editing tag '%s'\n", str
            str\gsub "&H......&", cfun
        alpha_replace = (str) ->
            aegisub.log 5, "editing tag '%s'\n", str
            str\gsub "&H..&", afun

        local cpattern, apattern, alphapattern
        if res.c1 or res.c2 or res.c3 or res.c4
            if res.hue != 0 or res.light != 0 or res.saturation != 0
                cpattern = make_base_pattern res, "c&H......&"
            if res.alpha != 0
                apattern = make_base_pattern res, "a&H..&"
        if res.full and res.alpha != 0
            alphapattern = "\\alpha&H..&"
        aegisub.log 5, "using patterns '%s', '%s', '%s'\n", cpattern, apattern, alphapattern
        for i in *sel
            line = sub[i]
            if cpattern     then line.text = line.text\gsub cpattern, color_replace
            if apattern     then line.text = line.text\gsub apattern, alpha_replace
            if alphapattern then line.text = line.text\gsub alphapattern, alpha_replace
            sub[i] = line

aegisub.register_macro script_name, script_description, main
