-- simple logger module for Reasons

log = (level) -> (msg, ...) ->
    if level
        aegisub.log level, "#{msg}\n", ...
    else
        aegisub.log "#{msg}\n", ...

lib = {
    fatal: log 0
    critical: log 0

    error: log 1

    warn: log 2
    warning: log 2

    hint: log 3
    info: log 3

    debug: log 4

    trace: log 5

    -- always shown
    print: log!
}

haveDepCtrl, DependencyControl, depctrl = pcall require, 'l0.DependencyControl'
if haveDepCtrl
    depctrl = DependencyControl {
        name: 'Logger',
        version: '0.1.0',
        description: [[Barebones convenience wrapper around aegisub.log]],
        author: "petzku",
        url: "https://github.com/petzku/Aegisub-Scripts",
        feed: "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json",
        moduleName: 'petzku.log'
    }
    lib.version = depctrl
    return depctrl\register lib
else
    return lib
