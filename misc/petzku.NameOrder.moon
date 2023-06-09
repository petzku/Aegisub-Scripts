-- names in intended order
NAMES = {
    "Kurokawa Akane",
    "Hoshino Aqua",
    "Hoshino Ruby",
    "Arima Kana",
}

reversed = [ name\gsub "(%w+) (%w+)", "%2 %1" for name in *NAMES ]

require 'karaskel'

-- operates on whole file, flagging any lines with wrong name order.
-- note that this _only_ flags the lines; fixing is left to the user
main = (sub, _sel) ->
    meta, styles = karaskel.collect_head sub, false
    for i, line in ipairs sub
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line_text meta, styles, line

        cont = line.text_stripped\gsub "%s*\\N%s*", " "
        for r in *reversed
            if cont\find r
                -- found wrong name order, flag and move on
                line.effect = "!! WRONG NAME ORDER !!"
                sub[i] = line
                break


aegisub.register_macro "Find wrong name orders", "", main
