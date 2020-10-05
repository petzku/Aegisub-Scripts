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
script_version = "0.5.0"
script_author = "petzku"
script_namespace = "petzku.Typewriter"

local DependencyControl = require("l0.DependencyControl")
local depctrl = DependencyControl{
    feed = "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json",
    {"aegisub.util", "unicode"}
}
local util, unicode = depctrl:requireModules()

function randomchar(ch, time)
    -- use time for deterministic random shuffle thing
    if ch == ch:lower() and ch ~= ch:upper() then
        local rand = math.pow((time + string.byte(ch:sub(1,1))) % 26, 10) % 26
        return string.char(97 + rand)
    elseif ch == ch:upper() and ch ~= ch:lower() then
        local rand = math.pow((time + string.byte(ch:sub(1,1))) % 26, 10) % 26
        return string.char(65 + rand)
    elseif tonumber(ch) ~= nil then --number
        local rand = math.pow((time + string.byte(ch:sub(1,1))) % 26, 10) % 10
        return string.char(48 + rand)
    else
        return ch
    end
end


function typewrite_by_duration(subs, sel)
    groups_to_add = {}
    for si, li in ipairs(sel) do
        local line = subs[li]

        local duration_frames = aegisub.frame_from_ms(line.end_time) - aegisub.frame_from_ms(line.start_time)
        local trimmed = util.trim(line.text:gsub("{.-}", ""))
        local line_len = unicode.len(trimmed)
        -- for some reason, this errors but the above works
        -- local line_len = unicode.len(util.trim(line.text:gsub("{.-}", "")))
        groups_to_add[#groups_to_add+1] = typewrite_line(line, duration_frames/line_len, li+1, generate_line)
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
    aegisub.set_undo_point("typewrite line length")
end

function typewrite_by_frame(subs, sel)
    local groups_to_add = {}
    for si, li in ipairs(sel) do
        local line = subs[li]
        groups_to_add[#groups_to_add+1] = typewrite_line(line, 1, li+1, generate_line)
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
    aegisub.set_undo_point("typewrite frame-by-frame")
end

function unscramble_by_duration(subs, sel)
    groups_to_add = {}
    for si, li in ipairs(sel) do
        local line = subs[li]

        local duration_frames = aegisub.frame_from_ms(line.end_time) - aegisub.frame_from_ms(line.start_time)
        local trimmed = util.trim(line.text:gsub("{.-}", ""))
        local line_len = unicode.len(trimmed)
        groups_to_add[#groups_to_add+1] = typewrite_line(line, duration_frames/line_len, li+1, generate_unscramble_lines)
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
    aegisub.set_undo_point("unscramble line length")
end


function typewrite_line(line, framedur, index, linefun)
    -- framedur: duration of single letter in frames, non-integer values will result in durations
    --           of floor(framedur) or ceil(framedur) creating a decent approximation over the line

    -- text with tags removed
    local raw_text = util.trim(line.text:gsub("{.-}", ""))
    local to_add = {}
    local start_tags = line.text:match("^{.-}") or ""
    local text = line.text:sub(start_tags:len()+1)

    local start_frame = aegisub.frame_from_ms(line.start_time)

    for i=1,unicode.len(raw_text) do
        local start = start_tags
        local rest = ""
        local n = 1
        local in_tags = false
        local active_char = ''

        for char in unicode.chars(text) do
            if n < i then
                start = start .. char
            elseif n == i then
                active_char = char
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

        local st = aegisub.ms_from_frame(start_frame + ((i-1) * framedur))
        local et = aegisub.ms_from_frame(start_frame + (i * framedur))

        lines = linefun(st, et, line, start, active_char, rest)

        for ii,new_line in ipairs(lines) do
            to_add[#to_add+1] = {index, new_line}
        end
    end
    -- continue the finished one until original line end
    to_add[#to_add][2].end_time = line.end_time
    return to_add
end

function generate_line(st, et, orig_line, start, char, rest)
    local SEPARATOR = "{\\alpha&HFF&}"

    local new = util.deep_copy(orig_line)
    new.start_time = st
    new.end_time = et
    start = start .. char

    -- hackfix for \N newline
    if start:sub(-1) == '\\' and rest:sub(1,1) == 'N' then
        new.text = start:sub(1, -2) .. SEPARATOR .. '\\' .. rest
        -- new.text = start
    elseif rest ~= "" then
        new.text = start .. SEPARATOR .. rest
    end

    return {new}
end

function generate_unscramble_halfway(st, et, orig_line, start, char, rest)
    local framedur = aegisub.frame_from_ms(et) - aegisub.frame_from_ms(st)

    return generate_unscramble_lines(st, et, orig_line, start, char, rest, math.floor(framedur/2))
end

function generate_unscramble_lines(st, et, orig_line, start, char, rest, staticframes)
    if not staticframes then staticframes = 1 end
    local SEPARATOR = "{\\alpha&HFF&}"
    local lines = {}

    local first_frame = aegisub.frame_from_ms(st)
    local last_frame = aegisub.frame_from_ms(et) - 1
    -- frame_from_ms gives the frame that contains the timestamp = the frame where the line shouldn't show up anymore

    for f = first_frame, last_frame do
        local new = util.deep_copy(orig_line)
        new.start_time = aegisub.ms_from_frame(f)
        new.end_time = aegisub.ms_from_frame(f+1)

        local newchar
        if (last_frame - f) < staticframes then
            newchar = char
        else
            newchar = randomchar(char, new.start_time)
        end
        -- hackfix for \N newline
        if start:sub(-1) == '\\' and char == "N" then
            new.text = start .. 'N' .. SEPARATOR .. rest
        elseif char == '\\' and rest:sub(1,1) == 'N' then
            new.text = start .. SEPARATOR .. '\\' .. rest
        elseif rest ~= "" then
            new.text = start .. newchar .. SEPARATOR .. rest
        else
            new.text = start .. newchar
        end
        lines[#lines+1] = new
    end
    return lines
end

depctrl:registerMacros{
    {"fbf", "Applies effect one char per frame", typewrite_by_frame},
    {"line", "Applies effect over duration of entire line", typewrite_by_duration},
    {"unscramble", "Applies unscrambling effect over duration of line", unscramble_by_duration}
}
