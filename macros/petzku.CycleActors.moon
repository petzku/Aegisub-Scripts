-- Copyright (c) 2023 petzku <petzku@zku.fi>

export script_name = "Cycle actor field"
export script_namespace = "petzku.CycleActors"
export script_version = "0.1.4"


trace = (s, ...) -> aegisub.log 5, s .. "\n", ...


collect_actors = (sub, first, last) ->
    actors = {}
    lookup = {}

    -- first, look backwards
    trace "Searching backwards from line %d", first-1
    for i = first-1, 1, -1
        line = sub[i]
        continue unless line.class == 'dialogue' and not line.comment and line.actor != ''
        continue if lookup[line.actor]
        trace "Found actor '%s' on line %d", line.actor, i
        table.insert actors, line.actor
        lookup[line.actor] = #actors
    trace "Found %d actors before", #actors

    tempacts = {}
    tempinv = {}
    -- next, forwards
    trace "Searching forwards line %d", last+1
    for i = last+1, #sub
        line = sub[i]
        continue unless line.class == 'dialogue' and not line.comment and line.actor != ''
        continue if lookup[line.actor] or tempinv[line.actor]
        trace "Found actor '%s' on line %d", line.actor, i
        table.insert tempacts, line.actor
        tempinv[line.actor] = true
    trace "Found %d actors after", #tempacts

    -- insert temp list in reverse order
    for i = #tempacts, 1, -1
        table.insert actors, tempacts[i]
        lookup[tempacts[i]] = #actors

    trace "Found %d total actors", #actors
    return actors, lookup


set_actors = (newact, sub, sel) ->
    for i in *sel
        trace "Setting actor '%s' on line %d", newact, i
        line = sub[i]
        line.actor = newact
        sub[i] = line

cycle_forward = (sub, sel) ->
    actors, index = collect_actors sub, sel[1], sel[#sel]
    firstline = sub[sel[1]]
    idx = index[firstline.actor] or 0
    if idx == 0
        trace "Didn't find actor '%s'. Starting from 0", firstline.actor
    else
        trace "Found actor '%s' at index %d", firstline.actor, idx
    newact = actors[(idx % #actors)+1]
    trace "Using next actor '%s' at index %d", newact, (idx % #actors)+1
    set_actors newact, sub, sel

cycle_back = (sub, sel) ->
    actors, index = collect_actors sub, sel[1], sel[#sel]
    firstline = sub[sel[1]]
    idx = index[firstline.actor]
    if idx == nil
        trace "Didn't find actor '%s'. Starting from %d", firstline.actor, #actors + 1
    else
        trace "Found actor '%s' at index %d", firstline.actor, idx
    idx = idx and idx > 1 and idx or #actors+1
    newact = actors[idx - 1]
    trace "Using previous actor '%s' at index %d", newact, idx - 1
    set_actors newact, sub, sel


aegisub.register_macro "#{script_name}/Forward", "", cycle_forward
aegisub.register_macro "#{script_name}/Backward", "", cycle_back
