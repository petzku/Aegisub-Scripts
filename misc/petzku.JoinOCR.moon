export script_name = "Join OCR"
export script_description = "Join simultaneous OCR'd lines into one event"
export script_author = "petzku"
export script_namespace = "petzku.JoinOCR"
export script_version = "0.1.0"

main = (sub, sel) ->
    -- note: iterating backwards so this is actually the _later_ line...
    pi = sel[#sel]
    for si = #sel-1, 1, -1 do
        prev = sub[pi]
        i = sel[si]
        line = sub[i]
        if line.start_time == prev.start_time and line.end_time == prev.start_time
            -- join lines, remove pos tags from later
            line.text = line.text .. "\\N" .. prev.text\gsub("{\\an%d\\pos%b()}", "", 1)
            sub.delete(pi)
            sub[i] = line

aegisub.register_macro script_name, script_description, main