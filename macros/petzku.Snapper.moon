export script_name = "Snapper"
export script_description = "Snaps line start and end times to keyframes"
export script_author = "petzku"
export script_namespace = "petzku.Snapper"
export script_version = "0.2.1"

_snap_start = (subs, sel) ->
    kfs = aegisub.keyframes!
    for i in *sel
        line = subs[i]
        frame = aegisub.frame_from_ms line.start_time
        new = 0
        for kf in *kfs
            if kf > new and kf <= frame
                new = kf

        line.start_time = aegisub.ms_from_frame new
        subs[i] = line

_snap_end = (subs, sel) ->
    kfs = aegisub.keyframes!
    for i in *sel
        line = subs[i]
        frame = aegisub.frame_from_ms line.end_time
        new = nil
        for kf in *kfs
            if (new == nil or kf < new) and kf >= frame
                new = kf

        line.end_time = aegisub.ms_from_frame new
        subs[i] = line

snap_start = (subs, sel) ->
    _snap_start subs, sel
    aegisub.set_undo_point "snap line start to previous keyframe"

snap_end = (subs, sel) ->
    _snap_end subs, sel
    aegisub.set_undo_point "snap line end to next keyframe"

snap_both = (subs, sel) ->
    _snap_start subs, sel
    _snap_end subs, sel
    aegisub.set_undo_point "snap line start and end to surrounding keyframes"

macros = {
    {'start', "Snaps line start to previous keyframe", snap_start},
    {'end', "Snaps line end to next keyframe", snap_end}
    {'both', "Snaps line start and end to surrounding keyframes", snap_both}
}
for macro in *macros
    name, desc, fun, cond = unpack macro
    aegisub.register_macro script_name..'/'..name, desc, fun, cond
