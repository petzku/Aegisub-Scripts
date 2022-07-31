-- Copyright (c) 2021, petzku <petzku@zku.fi>

export script_name =        "Fix Alpha and Colour Tags"
export script_description = [[Fixes "broken" alpha and colour tags by removing any excess values and inserting the wrapping &H..& as required]]
export script_author =      "petzku"
export script_namespace =   "petzku.FixAlphaTags"
export script_version =     "0.1.0"

-- US spelling because idk it's more common in code?
-- who am i kidding it's just to line these up nicer
-- meanwhile fuck lua patterns for not including OR patterns
alpha_pattern = "(\\[1-4]a)[&H]*([0-9a-fA-F]+)&*"
alpha2_pattern = "(\\alpha)[&H]*([0-9a-fA-F]+)&*"
color_pattern = "(\\[1-4]?c)[&H]*([0-9a-fA-F]+)&*"

format_alpha = (tag, value) ->
    tag .. '&H' .. value\sub(-2) .. '&'

format_color = (tag, value) ->
    tag .. '&H' .. value\sub(-6) .. '&'

main = (sub, sel) ->
    for i in *sel
        line = sub[i]
        line.text = line.text\gsub(alpha_pattern, format_alpha)\gsub(alpha2_pattern, format_alpha)\gsub(color_pattern, format_color)
        sub[i] = line

aegisub.register_macro(script_name, script_description, main)
