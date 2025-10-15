export script_name =        "Unsquish"
export script_description = "Undoes limited range color squishing (badly)"
export script_author =      "petzku"
export script_namespace =   "petzku.Unsquish"
export script_version =     "0.1.0"

util = require 'aegisub.util'
ln = require 'ln.kara'
-- KaraOK uses this without the 'util' prexix, because karaskel does weird stuff.
-- Export it manually, else the functions don't work.
export extract_color = util.extract_color

cfun = (color) ->
    r,g,b = ln.color.rgb.get(color)
    r = math.floor((r - 16) * 255 / 219 + 0.5)
    g = math.floor((g - 16) * 255 / 219 + 0.5)
    b = math.floor((b - 16) * 255 / 219 + 0.5)

    ln.color.byRGB(r, g, b)

color_replace = (str) ->
    str\gsub "&H......&", cfun

main = (sub, sel) ->
    cpattern = [[\[1-4]?c[&H]*......&?]]
    for i in *sel
        line = sub[i]
        line.text = line.text\gsub cpattern, color_replace
        sub[i] = line

aegisub.register_macro script_name, script_description, main
