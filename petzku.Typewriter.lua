-- Copyright (c) 2020, petzku <petzku@zku.fi>
--
-- Permission to use, copy, modify, and distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

--[[
==README==

Makes a line appear one character at a time, as if being written there and then.

Two macros: "fbf" starts at line start, adds one char per frame and leaves the finished
string until line end. "line" adds characters linearly spaced over the entire line's duration.

TODO: support rtl and/or bottom-to-top text?
TODO: consider behaving nicely with \move and \t

]]--

script_name = "Typewriter"
script_description = "Makes text appear one character at a time"
script_version = "0.3.1"
script_author = "petzku"
script_namespace = "petzku.Typewriter"

local DependencyControl = require("l0.DependencyControl")
local depctrl = DependencyControl{
    feed = "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/master/DependencyControl.json",
    {"aegisub.util", "karaskel", "unicode"}
}
local util, kara, unicode = depctrl:requireModules()

function typewrite_by_duration(subs, sel)
    local meta, styles = karaskel.collect_head(subs, false)
    groups_to_add = {}
    for si, li in ipairs(sel) do
        local line = subs[li]
        karaskel.preproc_line(subs, meta, styles, line)

        local duration = line.end_time - line.start_time * 1.0
        local trimmed = util.trim(line.text:gsub("{.-}", ""))
        local line_len = unicode.len(trimmed)
        -- for some reason, this errors but the above works
        -- local line_len = unicode.len(util.trim(line.text:gsub("{.-}", "")))
        groups_to_add[#groups_to_add+1] = typewrite_line(line, duration/line_len, li+1)
        -- comment the original line out
        line.comment = true
        subs[li] = line
    end
    for j=#groups_to_add, 1, -1 do
        local group = groups_to_add[j]
        for i=#group, 1, -1 do
            local index = group[i][1]
            local line = group[i][2]
            subs.insert(index, line)
        end
    end
    aegisub.set_undo_point("Typewrite line length")
end

function typewrite_by_frame(subs, sel)
    local meta, styles = karaskel.collect_head(subs, false)
    local groups_to_add = {}
    for si, li in ipairs(sel) do
        local line = subs[li]
        karaskel.preproc_line(subs, meta, styles, line)
        -- NOTE: assumes 23.976 fps, which usually matches for anime. query video data?
        groups_to_add[#groups_to_add+1] = typewrite_line(line, (1001.0 / 24), li+1)    
        -- comment the original line out
        line.comment = true
        subs[li] = line
    end
    for j=#groups_to_add, 1, -1 do
        local group = groups_to_add[j]
        for i=#group, 1, -1 do
            local index = group[i][1]
            local line = group[i][2]
            subs.insert(index, line)
        end
    end
    aegisub.set_undo_point("Typewrite frame-by-frame")
end

function typewrite_line(line, frametime, index)
    -- text with tags removed
    local raw_text = util.trim(line.text:gsub("{.-}", ""))
    local to_add = {}
    local SEPARATOR = "{\\alpha&HFF&}"

    for i=1,unicode.len(raw_text) do
        new = util.deep_copy(line)

        local start = ""
        local rest = ""
        local n = 1
        local in_tags = false
        for char in unicode.chars(line.text) do            
            if n <= i then
                start = start .. char
            else
                rest = rest .. char
            end

            if in_tags then
                if char == "}" then
                    in_tags = false
                end
            elseif char == "{" then
                in_tags = true
            else
                n = n + 1
            end
        end
        -- hackfix for \N newline
        if start:sub(-1) == '\\' and rest:sub(1,1) == 'N' then
            new.text = start:sub(1, -2) .. SEPARATOR .. '\\' .. rest
            -- new.text = start
        elseif rest ~= "" then
            new.text = start .. SEPARATOR .. rest
        end

        new.start_time = line.start_time + ((i - 1) * frametime)
        new.end_time = line.start_time + (i * frametime)

        to_add[#to_add+1] = {index, new}
    end
    -- continue the finished one until original line end
    to_add[#to_add][2].end_time = line.end_time
    return to_add
end

depctrl:registerMacros{
    {"fbf", "Applies effect one char per frame", typewrite_by_frame},
    {"line", "Apllies effect over duration of entire line", typewrite_by_duration}
}
