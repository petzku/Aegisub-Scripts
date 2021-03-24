[[
README

A bunch of different utility functions I use all over the place.
Or maybe I don't. But that's the plan, at least.

Anyone else is free to use this library too, but most of the stuff is specifically for my own stuff.
]]

-- "\" on windows, "/" on any other system
pathsep = package.config\sub 1,1

with lib = {}
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
