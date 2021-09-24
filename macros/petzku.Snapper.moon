export script_name = "Snapper"
export script_description = "Snaps line start and end times to keyframes"
export script_author = "petzku"
export script_namespace = "petzku.Snapper"
export script_version = "0.1.0"

snap_start = (subs, sel) ->
    kfs = aegisub.keyframes!
    for i in *sel
        line = subs[i]
        kf = do
            j = 1
            frame = aegisub.frame_from_ms line.start_time
            while kfs[j] <= frame
                j += 1
            aegisub.ms_from_frame kfs[j-1]

        line.start_time = kf
        subs[i] = line
    aegisub.set_undo_point "snap line start to previous keyframe"

snap_end = (subs, sel) ->
    kfs = aegisub.keyframes!
    for i in *sel
        line = subs[i]
        kf = do
            j = 1
            frame = aegisub.frame_from_ms line.end_time
            while kfs[j] < frame
                j += 1
            aegisub.ms_from_frame kfs[j]

        line.end_time = kf
        subs[i] = line
    aegisub.set_undo_point "snap line end to next keyframe"

snap_both = (subs, sel) ->
    snap_start subs, sel
    snap_end subs, sel

macros = {
    {'start', "Snaps line start to previous keyframe", snap_start},
    {'end', "Snaps line end to next keyframe", snap_end}
    {'both', "Snaps line start and end to surrounding keyframes", snap_both}
}
for macro in *macros
    name, desc, fun, cond = unpack macro
    aegisub.register_macro script_name..'/'..name, desc, fun, cond
