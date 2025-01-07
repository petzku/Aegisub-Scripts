export script_name = "Speakers from Sheet"
export script_description = "Copy speaker tags from a Google Sheets translation into Aegisub"
export script_author = "petzku"
export script_namespace = "petzku.SpeakersFromSheet"
export script_version = "0.0.1"



main = (sub, sel) ->
    btn, res = aegisub.dialog.display {{class: "textbox", name: "content", x: 0, y: 0, width: 10, height: 4, text: ""}}
    return unless btn

    i = sel[1]
    -- iterate over speaker names...
    for name in (res.content .. "\n")\gmatch "([^\n]*)\n"
        -- check that this wasn't an empty line,
        continue if name == ""
        -- and assign them to corresponding lines
        if '"' == sub[i].text\sub 1,1
            -- if this line started with a quotation mark, it is from a multiline cell
            -- and we should keep assigning this name to the following cells as well
            while true
                line = sub[i]
                line.actor = name
                sub[i] = line
                break if '"' == line.text\sub -1
                i += 1
        else
            -- single line
            line = sub[i]
            line.actor = name
            sub[i] = line
        i += 1


aegisub.register_macro script_name, script_description, main