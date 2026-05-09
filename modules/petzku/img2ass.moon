draw = (base, x, y, w, h, c) ->
    -- base = dialogue line containing relevant mask shape, just-add-clips style
    -- c = color triple as lua table (keyed r,g,b)
    newl = util.copy base
    newl.text = "{\\clip(#{x},#{y},#{x+w},#{y+h})\\c#{util.ass_color(c.r, c.g, c.b)}}" .. base.text
    newl


draw_shapes_naive = (base, x, y, w, h, img) ->
    -- base = dialogue line to base basic stuff off of (e.g. style, times, etc)
    --        text content will be wiped
    -- img = 1d table of colors, row-major (is this smart)

    lines = {}

    for i = 0, h-1 do
        for j = 0, w-1 do
            newl = draw base, x+j, y+i, 1, 1, img[1 + j + i*h]
            table.append lines, newl

    lines


draw_shapes_rle = (base, x, y, w, h, img) ->
    -- run-length optimization only
    lines = {}

    for i = 0, h-1 do
        -- collect the colors into a table first
        cols = {}
        for j = 0, w-1 do
            table.append cols, img[1 + j + i*h]
        -- then do RLE. this is very naïve but idrc, this isn't supposed to be final anyway
        runs = { {c: cols[1], w: 1} }
        for j = 2, #cols
            color = cols[j]
            if runs[#runs].c == color
                runs[#runs].w += 1
            else
                table.insert runs, {c: color, w: 1}
        -- then draw
        xx = x
        for run in *runs
            newl = draw base, xx, y+i, run.w, 1, run.c
            table.append lines, newl
            xx += run.w


-- how the *fuck* would we though
draw_shapes_smarter = (base, x, y, w, h, img) ->
    ...

img2ass = (base, x, y, w, h, img) ->
    -- base = dialogue line to base basic stuff off of (e.g. style, times, etc)
    --        text content will be wiped
    -- img = 1d table of colors, row-major (is this smart)

    base = util.copy base
    base.text = "{\\an7\\pos(#{x},#{y})\\p1}m 0 0 l #{w} 0 #{w} #{h} 0 #{h}"

    draw_shapes_naive(base, x, y, w, h, img)
