-- Copyright (c) 2024 petzku <petzku@zku.fi>

export script_name =        "Tile Clips"
export script_description = "Split lines into clipped sections"
export script_author =      "petzku"
export script_namespace =   "petzku.TileClip"
export script_version =     "0.0.1"

util = require 'aegisub.util'


EXTRA_KEY = script_namespace
CLIP_SIZE = 40
BUFFER_SIZE = 4

add_clip = (line, buffer, x, y) ->
    buf = if buffer then BUFFER_SIZE else 0
    x1 = (x-1) * CLIP_SIZE - buf
    y1 = (y-1) * CLIP_SIZE - buf
    x2 = x * CLIP_SIZE + buf
    y2 = y * CLIP_SIZE + buf
    line.text = "{\\clip(#{x1},#{y1},#{x2},#{y2})}#{line.text}"
    return line

add_clips = (line, buffer) ->
    -- check if extradata exists
    if line.extra[EXTRA_KEY]
        x, y = line.extra[EXTRA_KEY]\match "(%d+),(%d+)"
        return {add_clip line, buffer, x, y}
    else
        -- TODO: get from karaskel or something
        mx = 1920 / CLIP_SIZE
        my = 1080 / CLIP_SIZE
        lines = {}
        for x = 1, mx
            for y = 1, my
                ln = util.copy line
                ln.extra = util.copy line.extra
                ln.extra[EXTRA_KEY] = "#{x},#{y}"
                ln = add_clip ln, buffer, x, y
                table.insert lines, ln
        return lines


main = (buffer, sub, sel) ->
    for si = #sel, 1, -1
        i = sel[si]
        line = sub[i]
        lines = add_clips line, buffer
        sub.delete i
        for ln in *lines
            sub.insert i, ln

with_buffer = (...) -> main true, ...

no_buffer = (...) -> main false, ...

aegisub.register_macro "#{script_name}/With buffers", script_description, with_buffer
aegisub.register_macro "#{script_name}/Without buffers", script_description, no_buffer