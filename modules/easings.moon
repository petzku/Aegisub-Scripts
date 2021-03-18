-- Copyright (c) 2021, petzku <petzku@zku.fi>
[[
README

A library of (hopefully) easy-to-use easing functions for transforms.

https://easings.net/

]]

require 'moonscript'
petzku = require 'petzku.util'

-- best-effort estimation, assuming CFR
get_framedur = () ->
    (aegisub.ms_from_frame 10001 - aegisub.ms_from_frame 1) / 10000

-- Ensure tags is a list-of-triples, not a single triple
wrap_tags = (tags) ->
    if type tags[1] != "table"
        {tags}
    else
        tags

-- TODO: maybe work with colours? idk
-- params:
--  tags: table of {"tag", start_value, end_value} triples
--  alternatively a single such triple
--  t1, t2: start and end times, respectively
-- returns:
--  string of '\t' tags, approximating the given easing function
easer = (tags, t1, t2, fun) ->
    tags = wrap_tags tags
    frame = get_framedur!
    dt = t2 - t1
    
    strbuf = {}
    -- first: set start values
    table.insert strbuf, string.format "\\t(%d,%d,", t1, t1-1
    for tse in *tags
        t, s, e = unpack tse
        table.insert strbuf, string.format "\\%s%.2f", t, s
    table.insert strbuf, ")"

    x = 0
    while x <= dt
        x2 = math.min dt, x + 2*frame

        r1 = fun x / dt
        rh = fun((x + frame) / dt)
        r2 = fun x2 / dt

        accel = petzku.transform.calc_accel(r1, rh, r2)

        table.insert strbuf, string.format "\\t(%d,%d,%.2f,", t1 + x, t1 + x2, accel
        for tse in *tags
            tag, s, e = unpack tse
            value = s + r2 * (e - s)
            table.insert strbuf, string.format "\\%s%.2f", tag, value
        table.insert strbuf, ")"
        x += 2 * frame

    table.concat strbuf

make_easer = (fun) -> (tags, t1, t2) -> easer(tags, t1, t2, fun)

ease_out_bounce = (t) ->
    -- what are all these magical constants?
    n1 = 7.5625
    d1 = 2.75

    if t < 1 / d1
        n1 * t * t
    elseif t < 2 / d1
        t -= 1.5 / d1
        n1 * t * t + 0.75
    elseif t < 2.5 / d1
        t -= 2.25 / d1
        n1 * t * t + 0.9375
    else
        t -= 2.625 / d1
        n1 * t * t + 0.984375

ease_in_bounce = (t) ->
    1 - (ease_out_bounce 1-t)

ease_inout_bounce = (t) ->
    if t < 0.5
        (1 - ease_out_bounce(1 - 2*t)) / 2
    else
        (1 + ease_out_bounce(2*t - 1)) / 2

ease_out_back = (t) ->
    c1 = 1.70158
    c3 = c1 + 1
    1 + c3 * math.pow(x-1, 3) + c1 * pow(x-1, 2)

ease_in_back = (t) ->
    c1 = 1.70158
    c3 = c1 + 1
    c3 * math.pow(x, 3) - c1 * pow(x, 2)

ease_inout_back = (t) ->
    c1 = 1.70158
    c2 = c1 * 1.525
    if x < 0.5
        (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2

ease_out_circle = (t) ->
    math.sqrt 1 - math.pow x - 1, 2

ease_in_circle = (t) ->
    1 - math.sqrt 1 - x * x

ease_inout_circle = (t) ->
    math.sqrt 1 - math.pow x - 1 , 2

with easings = {}
    .out_bounce = make_easer ease_out_bounce
    .in_bounce = make_easer ease_in_bounce
    .inout_bounce = make_easer ease_inout_bounce

    .out_back = make_easer ease_out_back
    .in_back = make_easer ease_in_back
    .inout_back = make_easer ease_inout_back

    .out_circle = make_easer ease_out_circle
    .in_circle = make_easer ease_in_circle
    .inout_circle = make_easer ease_inout_circle

    .linear = make_easer (t) -> t

    -- convenience aliases
    .i = {
        bounce: .in_bounce
        back: .in_back
        circle: .in_circle
    }
    .o = {
        bounce: .out_bounce
        back: .out_back
        circle: .out_circle
    }
    .io = {
        bounce: .inout_bounce
        back: .inout_back
        circle: .inout_circle
    }

    .bounce = {
        i: .in_bounce
        o: .out_bounce
        io: .inout_bounce
    }
    .back = {
        i: .in_back
        o: .out_back
        io: .inout_back
    }
    .circle = {
        i: .in_circle
        o: .out_circle
        io: .inout_circle
    }
