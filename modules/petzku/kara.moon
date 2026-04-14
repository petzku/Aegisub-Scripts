-- Copyright (c) 2025, petzku <petzku@zku.fi>

local tenv

lib = with {}
    .init = (tv) ->
        tenv = tv
        tenv.mst = .time.min_syltime
    .time = {
        -- clamp end time of current line to start time (incl. lead-in) of next line
        --      leadin: offset to be applied to next line's start time. negative values = added lead-in (to match retime syntax)
        clamp_end: (leadin = 0) ->
            -- make sure next line exists and would overlap current
            return unless tenv.orgline.next and tenv.line.end_time > (tenv.orgline.next.start_time + leadin)
            -- and that the next line isn't _entirely_ before our current one (i.e. avoid accidentally trimming when changing languages)
            return if tenv.orgline.next.end_time < tenv.line.start_time
            tenv.line.end_time = tenv.orgline.next.start_time + leadin
            tenv.line.duration = tenv.line.end_time - tenv.line.start_time

        -- Calculate the minimum between two values, relative to syl duration:
        -- Either `syl.start_time + syl.duration * frac` or `syl.start_time + offset`.
        -- Optionally, instead uses `syl.start_time + offset_frac * syl.duration + offset` if specified
        min_syltime: (frac, offset, offset_frac = 0) ->
            math.min(
                tenv.syl.start_time + tenv.syl.duration * frac,
                tenv.syl.start_time + tenv.syl.duration * offset_frac + offset
            )
    }
    .multilayer = (n, offset=0) ->
        tenv.maxloop 'layer', n
        tenv.relayer tenv.loopctx.state.layer + offset

lib
