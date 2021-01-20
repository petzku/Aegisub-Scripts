-- Generate info boxes for Cells at Work

script_name = "Cells Box"
script_description = "Generate info boxes for Cells at Work"
script_author = "petzku"
script_version = "0.1.0"
script_namespace = "petzku.CellsBox"

require 'karaskel'
local util = require 'aegisub.util'

function make_transforms(fstart, fend, dur)
    local str = ""
    if tonumber(fstart) > 0 then
        str = string.format("\\1a&HFF&\\t(%d,%d,\\1a&H00&)", fstart - 40, fstart)
    end
    if tonumber(fend) > 0 then
        str = str .. string.format("\\t(%d,%d,\\1a&HFF&)", dur - fend, dur - fend + 40)
    end
    return str
end

function generate_box(subs, sel)
    local meta, styles = karaskel.collect_head(subs, false)
    local new_sel = {}
    for si = #sel,1,-1 do
        local li = sel[si]
        local line = subs[li]
        karaskel.preproc_line(subs, meta, styles, line)
        local style = util.copy(line.styleref)

        -- separate header and body text
        local header = line.text_stripped:match("(.-)\\N")
        local body = line.text_stripped:sub(header:len()+1) .. "\\N" --hack to make parsing easier
        aegisub.log(4, "header: %s\nbody: %s\n", header, body)

        -- header stuff (TODO: maybe read these from the line itself)
        style.bold = true
        local width, height = aegisub.text_extents(style, header)
        aegisub.log(4, "w,h: %d,%d\n", width, height)
        -- and set to body text properties
        style.bold = false
        style.fontsize = 45
        for str in body:gmatch("(.-)\\N") do
            local w,h = aegisub.text_extents(style, str)
            width = math.max(width, w)
            height = height + h
            aegisub.log(4, "adding: %d,%d => %d,%d\n", w,h, width,height)
        end

        -- lift original text, then add two-layered box
        line.layer = line.layer + 2
        subs[li] = line

        local drawing = string.format("m -25 0 l %d 0 %d %d -25 %d", width+20, width+20, height+35, height+35)
        local pos = line.text:match("(\\pos%(.-%))")
        local fad, fstart, fend = line.text:match("(\\fad%((.-),(.-)%))")

        local box, border = util.copy(line), util.copy(line)
        box.text = "{"..pos.."\\c&HFFFFFF&\\4a&HFF&\\blur1"..fad.."\\p1}"..drawing
        box.layer = box.layer - 1
        border.text = "{"..pos.."\\bord2.5\\blur1"..fad..make_transforms(fstart, fend, line.duration).."\\p1}"..drawing
        border.layer = border.layer - 2
        subs.insert(li, box)
        subs.insert(li, border)
    end
    return new_sel
end

aegisub.register_macro(script_name, script_description, generate_box)
