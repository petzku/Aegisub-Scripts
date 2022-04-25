export script_name = "Join CCs"
export script_description = "Join consecutive 'split' lines in CCs"
export script_author = "petzku"
export script_namespace = "petzku.JoinCCs"
export script_version = "0.1.0"

punctuation_pattern = '[.,!?—-]"?$'

clean_text = (line) ->
    line\gsub("&gt;&gt;.+:", "")\gsub("‐‐", "—")\gsub("‐", "-")

get_first_dialogue_index = (subs) ->
    for i,line in ipairs subs
        if line.class == 'dialogue'
            return i

main = (subs, _) ->
    first = get_first_dialogue_index subs
    for i = #subs, first, -1
        line = subs[i]
        line.text = clean_text line.text
        -- check if merge necessary
        if not line.text\match punctuation_pattern
            -- this line isn't "final"
            -- merge with next line, delete next line
            next = subs[i+1]
            line.text = line.text .. " " .. next.text
            line.end_time = next.end_time
            subs.delete(i+1)
        subs[i] = line

    aegisub.create_undo_point("join CC lines")

aegisub.register_macro script_name, script_description, main
