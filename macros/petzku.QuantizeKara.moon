script_name = "Quantize K-timing"
script_description = "Quantize \\k-tags to discrete beats"

require 'karaskel'

round = (x) -> math.floor x + 0.5

-- bpm (quarter notes)
bpm = 156 / 2

-- ms duration of 16th (triplets dont exist)
quant16 = -> 60 * 1000 / bpm / 4

main = (sub, sel) ->
    quant = quant16!
    meta, style = karaskel.collect_head sub, false
    for i in *sel
        line = sub[i]
        karaskel.preproc_line sub, meta, style, line

        line.text = ""
        local last_offset

        for syl in *line.kara
            -- first syl
            if not last_offset
                last_offset = 0
                -- blank first syl
                if syl.text_stripped == ""
                    -- ignore this syl. assume its end time is accurate; only adjust all following syls
                    line.text ..= "{#{syl.tag}#{syl.duration/10}}"
                    last_offset
                    continue

            dur16ths = (last_offset + syl.duration) / quant
            aegisub.log "%s + %s = %s", last_offset, syl.duration, last_offset+syl.duration
            -- round to nearest 16th
            newdur = quant * round dur16ths
            -- round to cs and replace into text
            newkdur = round newdur / 10
            aegisub.log " -> %s (%s) ~ %s", newdur, dur16ths, (newkdur * 10)

            last_offset = (last_offset + syl.duration) - (10 * newkdur)
            newtag = "{#{syl.tag}#{newkdur}}"
            aegisub.log " (%s)\n", last_offset

            -- we might *want to* use gsub, but since we must do replacements one at a time, it's better to rebuild the line ourself
            -- this also means we get to avoid other kinds of dumb shit
            line.text ..= newtag .. syl.text
        sub[i] = line

aegisub.register_macro script_name, script_description, main
