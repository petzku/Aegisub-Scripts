-- Copyright 2021 (c) petzku <petzku@zku.fi>

haveDepCtrl, DependencyControl, depctrl = pcall require, 'l0.DependencyControl'
if haveDepCtrl
    depctrl = DependencyControl {
        name: 'Formatter',
        version: '0.1.0',
        description: [[Format strings more sensibly]],
        author: "petzku",
        url: "https://github.com/petzku/Aegisub-Scripts",
        moduleName: 'petzku.format'
    }

lib = {}
with lib
    -- format `num` as a decimal with at most `max_places` decimal places.
    -- trailing zeroes will be stripped.
    .decimal = (num, max_places) ->
        string.format("%%.%df", max_places)\format(num)\gsub("%.?0+", "")

if haveDepCtrl
    lib.version = depctrl
    return depctrl\register lib
else
    return lib
