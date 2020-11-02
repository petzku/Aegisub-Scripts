-- Copyright (c) 2020, petzku <petzku@zku.fi>

--[[ README
Prepares lines for a rainbow gradient:
- Calculates required gradient strip width to get at most 100 strips
- Copies line once per desired color and sets \3c respectively
]]
local tr = aegisub.gettext

script_name = tr "Prepare Gradient"
script_description = tr "Prepare lines for a rainbow gradient"
script_author = "petzku"
script_namespace = "petzku.PrepGradient"
script_version = "0.1.0"

local util, kara = require 'aegisub.util', require 'karaskel'

local COLORS = {"&H0000FF&", "&H00AEFF&", "&H00FFF7&", "&H00FF4A&", "&HCAFF00&", "&HFF1C00&"}

function process_line(line)
    local width = line.width + line.styleref.outline
    local strip_width = math.floor(0.5 + width / 100) -- works as long as lines are at least 50px wide
    
    local lines = {}
    for i,c in ipairs(COLORS) do
        local l = util.copy(line)
        l.actor = ("strip: %dpx (%d)"):format(strip_width, math.ceil(width/strip_width)) .. l.actor
        l.text = ("{\\3c%s}"):format(c) .. l.text
        lines[i] = l
    end
    return lines
end

function prepare_gradient(subs, sel)
    local meta, styles = karaskel.collect_head(subs, false)
    local groups = {}

    for si, li in ipairs(sel) do
        local line = subs[li]
        karaskel.preproc_line(subs, meta, styles, line)
        if not line.comment then
            table.insert(groups, {li, process_line(line)})
            line.comment = true
            subs[li] = line
        end
    end

    for i = #groups, 1, -1 do
        local li, lines = unpack(groups[i])
        subs.insert(li+1, unpack(lines))
    end
    aegisub.set_undo_point("prepare lines for rainbow gradient")
end

aegisub.register_macro(script_name, script_description, prepare_gradient)
