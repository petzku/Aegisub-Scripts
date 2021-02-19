-- Copyright (c) 2021 petzku <petzku@zku.fi> 

export script_name =        "Position to Margin"
export script_description = "Transforms \\pos-based motion-tracking into margin-based"
export script_author =      "petzku"
export script_namespace =   "petzku.PosToMargin"
export script_version =     "0.2.0"

-- Assumes \an2, because I'm lazy as shit. This is only meant for use with dialogue anyway.
-- Support for other alignments is on the TODO, \an8 probably being the most relevant one.

require 'karaskel'

get_playres = (subs) ->
    local x, y
    for line in *subs
        if line.class == 'info'
            if line.key == 'PlayResX'
                x = tonumber line.value
            elseif line.key == 'PlayResY'
                y = tonumber line.value
            if x and y
                break
    return x, y

margin_y_from_pos = (line, posy, height) ->
    -- assume text is \an2 => position from bottom maps directly to desired vertical margin
    margin = math.floor(height - posy + 0.5)
    line.margin_t = margin

margin_x_from_pos = (line, posx, width) ->
    -- assume text is middle-aligned (i.e. one of 2,5,8)
    offset = posx - (width / 2)
    margin_l = if line.margin_l != 0 then line.margin_l else line.styleref.margin_l
    margin_r = if line.margin_r != 0 then line.margin_r else line.styleref.margin_r

    margin_l += offset
    margin_r -= offset

    -- ensure margins are always positive (likely will cause reflows for long-ish text)
    -- apparently both libass and vsfilter support negative margins, so we can just rely on those
    -- if margin_l < 0
    --     margin_r += (1 - margin_l)
    --     margin_l = 1
    -- elseif margin_r < 0
    --     margin_l -= (1 - margin_r)
    --     margin_r = 1

    -- ensure line margins are non-zero (i.e. do not read from style)
    -- might possibly cause reflows in very edge cases!
    if margin_l == 0
        margin_l = -1
        margin_r -= 1
    if margin_r == 0
        margin_r = -1
        margin_l -= 1

    line.margin_l = math.floor(margin_l + 0.5)
    line.margin_r = math.floor(margin_r + 0.5)

remove_pos = (line) ->
    line.text = line.text\gsub("\\pos%b()", "", 1)
    -- in case position is the only tag, clean up the block too
    line.text = line.text\gsub("{}", "", 1)

main = (subs, sel) ->
    width, height = get_playres subs
    meta, styles = karaskel.collect_head subs, false

    for i in *sel
        line = subs[i]
        karaskel.preproc_line subs, meta, styles, line

        posx, posy = line.text\match("\\pos%((-?[%d.]+),(-?[%d.]+)%)")
        unless posx continue

        margin_y_from_pos line, posy, height
        margin_x_from_pos line, posx, width

        remove_pos line

        subs[i] = line

can_run = (subs, sel) ->
    -- check that at least one line in selection has a position tag, otherwise we'd be doing nothing
    for i in *sel
        line = subs[i]
        if line.text\match "\\pos%b()"
            return true
    return false

aegisub.register_macro(script_name, script_description, main, can_run)
