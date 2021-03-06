[[
README

A bunch of different utility functions I use all over the place.
Or maybe I don't. But that's the plan, at least.

Anyone else is free to use this library too, but most of the stuff is specifically for my own stuff.
]]

haveDepCtrl, DependencyControl, depctrl = pcall require, 'l0.DependencyControl'
local util
if haveDepCtrl
    depctrl = DependencyControl {
        name: 'petzkuLib',
        version: '0.3.0',
        description: [[Various utility functions for use with petzku's Aegisub macros]],
        author: "petzku",
        url: "https://github.com/petzku/Aegisub-Scripts",
        moduleName: 'petzku.util',
        {
            "aegisub.util"
        }
    }
    util = depctrl\requireModules!
else
    util = require "aegisub.util"

-- "\" on windows, "/" on any other system
pathsep = package.config\sub 1,1

lib = {}
with lib
    .math = {
        log_n: (base, x) ->
            math.log(x) / math.log(base)

        clamp: (x, low, high) ->
            math.min(math.max(low, x), high)
    }

    .transform = {
        -- Calculate the accel value required to make a transform match the midpoint of an arbitrary function
        --   logic borrowed from logarithm:
        --   Assumed ASS accel curve:
        --     ratio = ((t - t0) / (t1 - t0)) ^ accel
        --     value = val0 + (val1 - val0) * ratio
        --   Ratio range is 0-1 so exponent just curves it.
        --   knowns:
        --     value = valHalf
        --     ((t - t0) / (t1 - t0)) = 0.5
        --   since we're halfway through the timestep, so:
        --     ratio = 0.5 ^ accel
        --   place the knowns into the latter equation:
        --     valHalf = val0 + (val1 - val0) * 0.5 ^ accel
        --     (valHalf - val0) / (val1 - val0) = 0.5 ^ accel
        --     log_0.5( (valHalf - val0) / (val1 - val0) ) = log_0.5(0.5^accel) = accel
        calc_accel: (val0, valhalf, val1) ->
            accel = .math.log_n 0.5, math.abs (valhalf - val0) / (val1 - val0)
            -- clamp to a sensible interval just in case
            .math.clamp accel, 0.01, 100

        -- Retime transforms, move tags and fades
        -- Params:
        --   line: Either a line object or a string.
        --         A line object should be karaskel preproc'd (does it need to be?).
        --         If a string, duration should be given, or simple (line start to line end) tags can't be shifted
        --   delta: Time in milliseconds to shift the transform.
        --          Positive values will shift forward, negative will shift backward.
        --          i.e. delta should be original_start_time - new_start_time
        --   duration: Duration of the line. Ignored if a line object is supplied.
        retime: (line, delta, duration) ->
            str = line
            if type(line) == 'table'
                line = util.copy line
                duration = line.end_time - line.start_time
                str = line.text

            -- rt = retime, s = simple, a = accel
            rt_t = (t1, t2) -> string.format "\\t(%d,%d,", t1+delta, t2+delta
            rt_at = (a) -> rt_t(0, duration) .. a .. ",\\"
            rt_st = () -> rt_t(0, duration) .. "\\"
            rt_move = (x,y,xx,yy,t1,t2) -> string.format "\\move(%s,%s,%s,%s,%d,%d)", x,y,xx,yy, t1+delta, t2+delta
            rt_smove = (x,y,xx,yy) -> rt_move x,y,xx,yy,0,duration
            rt_fade = (a1,a2,a3,t1,t2,t3,t4) -> string.format "\\fade(%s,%s,%s,%d,%d,%d,%d)", a1,a2,a3, t1+delta, t2+delta, t3+delta, t4+delta
            rt_sfade = (t_start, t_end) -> rt_fade 255,0,255, 0,t_start, duration-t_end,duration

            n = "[-%d.]+"
            -- p = pattern, s = simple, a = accel
            p_t     = "\\t%(("..n.."),("..n.."),"
            p_at    = "\\t%(("..n.."),\\"
            p_st    = "\\t%(\\"
            p_move  = "\\move%(("..n.."),("..n.."),("..n.."),("..n.."),("..n.."),("..n..")%)"
            p_smove = "\\move%(("..n.."),("..n.."),("..n.."),("..n..")%)"
            p_fade  = "\\fade?%(("..n.."),("..n.."),("..n.."),("..n.."),("..n.."),("..n.."),("..n..")%)"
            p_sfade = "\\fade?%(("..n.."),("..n..")%)"

            str = str\gsub(p_t, rt_t)\gsub(p_at, rt_at)\gsub(p_st, rt_st)\gsub(p_move, rt_move)\gsub(p_smove, rt_smove)\gsub(p_fade, rt_fade)\gsub(p_sfade, rt_sfade)

            if type(line) == 'table'
                line.text = str
                line
            else
                str
    }

    .io = {
        :pathsep,
        run_cmd: (cmd, quiet) ->
            aegisub.log 'running: %s\n', cmd unless quiet

            local output
            if pathsep == '\\'
                -- command lines over 256 bytes don't get run correctly, make a temporary file as a workaround
                tmp = aegisub.decode_path('?temp' .. pathsep .. 'tmp.bat')
                f = io.open tmp, 'w'
                f\write cmd
                f\close!

                p = io.popen tmp
                output = p\read '*a'
                p\close!

                os.execute 'del ' .. tmp
            else
                -- on linux, we should be fine to just execute the command directly
                p = io.popen cmd
                output = p\read '*a'
                p\close!

            aegisub.log output unless quiet
            output
    }

if haveDepCtrl
    lib.version = depctrl
    return depctrl\register lib
else
    return lib
