-- Copyright (c) 2022 petzku <petzku@zku.fi>

export script_name =        "Split prosubs"
export script_description = [[Splits the prosub-typical "- x\N- y" into separate lines]]
export script_author =      "petzku"
export script_namespace =   "petzku.ProsubSplit"
export script_version =     "0.2.0"

re = require "aegisub.re"

main = (sub, sel) ->
    if #sel < 2
        -- single line selection => run on whole file
        sel = [i for i = 1, #sub]
    for i = #sel, 1, -1
        line = sub[sel[i]]
        if line.class == "dialogue" and line.comment == false and line.text\match "^-+"
            text = line.text
            for j, part in ipairs re.split text, [[(^|\s*\\N\s*)-+\s?\b]], true
                line.text = part
                sub.insert sel[i] + j, line
            sub.delete sel[i]

aegisub.register_macro script_name, script_description, main
