-- find frame based on certain pixels

export script_name = "Find Frame"

util = require "aegisub.util"

main = (sub, sel) ->
    -- assume selection is all points for a given frame
    -- naïve method: try every frame from start of video until the end
    -- aegisub doesn't provide us with the full duration (afaik), so we use the last keyframe
    lastkf = aegisub.keyframes()[#aegisub.keyframes()]

    poscol = {}
    for i in *sel
        line = sub[i]
        x, y = line.text\match "\\pos%(([-%d.]+),([-%d.]+)%)"
        color = line.text\match "\\c(%b&&)"
        r, g, b = util.extract_color color

        table.insert poscol, {x: x, y: y, c: {r: r, g: g, b: b}}

    local match_frame
    for fr = 1, lastkf
        -- update progress for user
        aegisub.progress.set fr / lastkf * 100
        aegisub.progress.task "Finding matching frame... #{fr}/#{lastkf}"
        if aegisub.progress.is_cancelled!
            aegisub.cancel!
            return
        -- test all the points on this frame
        frame = aegisub.get_frame fr
        found_match = true
        for pc in *poscol
            frcol = frame\getPixelFormatted pc.x, pc.y
            r, g, b = util.extract_color frcol
            -- exit as early as possible: if any component of any pixel is off, go to next frame
            unless math.abs(r - pc.c.r) < 2 and math.abs(g - pc.c.g) < 2 and math.abs(b - pc.c.b) < 2
                found_match = false
                break
        if found_match
            match_frame = fr
            break
        collectgarbage("collect")

    -- correct frame found, retime lines to that frame
    for i in *sel
        line = sub[i]
        line.start_time = aegisub.ms_from_frame match_frame
        sub[i] = line


get_colors = (sub, sel) ->
    -- copy frame color on line position at its start time
    for i in *sel
        line = sub[i]
        x, y = line.text\match "\\pos%(([-%d.]+),([-%d.]+)%)"
        fr = aegisub.frame_from_ms line.start_time

        frame = aegisub.get_frame fr
        colorstr = frame\getPixelFormatted x, y
        line.text ..= "{\\c#{colorstr}}"
        sub[i] = line
    -- now, the lines can be pasted in another file, and compared

aegisub.register_macro "#{script_name}/Get Colors", "", get_colors
aegisub.register_macro "#{script_name}/Find Frame", "", main
