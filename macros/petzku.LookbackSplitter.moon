-- Copyright (c) 2021 petzku <petzku@zku.fi> 

export script_name =        "Lookback Splitter"
export script_description = "Split any lines in selection to segments at most 10 seconds in length"
export script_author =      "petzku"
export script_namespace =   "petzku.LookbackSplitter"
export script_version =     "1.0.0"

havedc, DependencyControl = pcall require, "l0.DependencyControl"
local dep, util
if havedc
    dep = DependencyControl{{'util'}}
    util = dep\requireModules!
else
    util = require 'aegisub.util'


MAX_DURATION = 9000 -- milliseconds

calc_end_time = (start) ->
    temp = aegisub.ms_from_frame aegisub.frame_from_ms start + MAX_DURATION
    -- nil if no video loaded
    temp or start + MAX_DURATION

main = (subs, sel) ->
    for si = #sel,1,-1
        i = sel[si]
        line = subs[i]
        if line.end_time - line.start_time < MAX_DURATION
            continue
        
        k = 1
        st = line.start_time
        et = math.min line.end_time, calc_end_time line.start_time
        while st < line.end_time
            new = util.copy line
            new.start_time = st
            new.end_time = et
            subs.insert i+k, new

            st = et
            et = math.min line.end_time, calc_end_time st
            k += 1
        subs.delete i

if havedc
    dep\registerMacro main
else
    aegisub.register_macro script_name, script_description, main
