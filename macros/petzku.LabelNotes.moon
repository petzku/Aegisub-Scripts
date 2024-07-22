MATCH = "{NN:"
LABEL = "NN"

main = (sub, sel) ->
    for i, line in ipairs sub
        continue unless line.class == "dialogue"
        if line.text\find MATCH, 1, true
            if line.effect == ""
                line.effect = LABEL
            else
                line.effect..= ";" .. LABEL
        sub[i] = line

aegisub.register_macro "Label lines with #{LABEL} notes", "", main