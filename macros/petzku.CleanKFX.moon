-- clean kfx and uncomment the karaoke lines

export script_name = "Clean Karaoke Effects"
export script_description = "Remove any fx lines, generated from k-templates, and uncomment all karaoke input lines"
export script_author = "petzku"
export script_namespace = "petzku.CleanKFX"
export script_version = "0.1.0"

main = (sub) ->
    for i = #sub, 1, -1
        line = sub[i]
        unless line.class == "dialogue" continue
        if line.comment and (line.effect == "kara" or line.effect == "karaoke")
            line.comment = false
            sub[i] = line
        elseif not line.comment and line.effect == "fx"
            sub.delete(i)

can_run = (sub) ->
    -- check if file contains generated effects _or_ commented kara lines
    for line in *sub
        continue unless line.class == "dialogue"
        return true if line.comment and (line.effect == "kara" or line.effect == "karaoke")
        return true if not line.comment and line.effect == "fx"
    false

aegisub.register_macro script_name, script_description, main, can_run
