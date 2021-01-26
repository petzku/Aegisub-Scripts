-- Generate info boxes for Cells at Work

script_name = "Cells Box"
script_description = "Generate info boxes for Cells at Work"
script_author = "petzku"
script_version = "0.2.0"
script_namespace = "petzku.CellsBox"

require 'karaskel'
local util = require 'aegisub.util'

function make_transforms(fstart, fend, dur)
    local str = ""
    if fstart and tonumber(fstart) > 0 then
        str = string.format("\\1a&HFF&\\t(%d,%d,\\1a&H00&)", fstart - 40, fstart)
    end
    if fend and tonumber(fend) > 0 then
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

        -- needed for line positioning etc
        local fad, fstart, fend = line.text:match("(\\fad%((.-),(.-)%))")
        fad = fad or ""
        local pos = line.text:match("(\\pos%(.-%))")
        local x, y = pos:match("%((%-?[%d.]+),(%-?[%d.]+)%)")

        -- lift the base line, we'll add a box underneath it later
        line.layer = line.layer + 2
        -- computing the y-coord is left for later
        line.text = ("{\\an1\\pos(%d,%%d)\\b1\\blur0.7%s}%s"):format(x, fad, header:gsub("%s+$",""))

        -- set style settings to body text properties
        style.bold = false
        style.fontsize = 45

        local nlines = {}

        for str in body:gmatch("(.-)\\N") do
            local w,h = aegisub.text_extents(style, str)
            width = math.max(width, w)
            height = height + h
            aegisub.log(4, "adding: %d,%d => %d,%d\n", w,h, width,height)

            if h > 0 then
                local nline = util.copy(line)
                nline.text = ("{\\an1\\pos(%d,%%d)\\fs45\\blur0.7%s}%s"):format(x, fad, str:gsub("%s+$",""))
                table.insert(nlines, nline)
            end
        end

        -- now that we know box height, we can calculate y-coords
        y = y + height/2
        -- replace original text
        for i = #nlines,1,-1 do
            local l = nlines[i]
            l.text = l.text:format(y)
            subs.insert(li+1, l)
            y = y - style.fontsize
        end
        line.text = line.text:format(y)
        subs[li] = line

        -- draw box and border
        local drawing = string.format("m -25 0 l %d 0 %d %d -25 %d", width+25, width+25, height+35, height+35)

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
