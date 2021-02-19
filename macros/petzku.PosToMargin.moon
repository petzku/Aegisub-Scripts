-- Copyright (c) 2021 petzku <petzku@zku.fi> 

export script_name =        "Position to Margin"
export script_description = "Transforms \\pos-based motion-tracking into margin-based"
export script_author =      "petzku"
export script_namespace =   "petzku.PosToMargin"
export script_version =     "1.0.1"

havedc, DependencyControl, dep = pcall require, "l0.DependencyControl"
if havedc
    dep = DependencyControl{{'karaskel'}}
    dep\requireModules!
else
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
    an = line.text\match "\\an(%d)"
    valign = line.valign
    if an
        valign = switch math.floor((an - 1) / 3)
            when 0 then "bottom"
            when 1 then "middle"
            when 2 then "top"

    margin = switch valign
        when "top"
            math.floor(posy + 0.5)
        when "bottom"
            math.floor(height - posy + 0.5)
        else
            -- \an456 doesn't respect vertical margins at all
            return

    aegisub.log 4, "margin (%s): %s\n", type(margin), margin
    line.margin_t = margin

margin_x_from_pos = (line, posx, width) ->
    an = line.text\match "\\an(%d)"
    halign = line.halign
    if an
        halign = switch an % 3
            when 0 then "right"
            when 1 then "left"
            when 2 then "center"

    -- preserve the "width" of the available space, should ensure text never reflows accidentally.
    org_margin_l = if line.margin_l != 0 then line.margin_l else line.styleref.margin_l
    org_margin_r = if line.margin_r != 0 then line.margin_r else line.styleref.margin_r
    buffer = (org_margin_l + org_margin_r) / 2

    local margin_l, margin_r
    switch halign
        when "center"
            offset = posx - (width / 2)
            margin_l = buffer + offset
            margin_r = buffer - offset
        when "left"
            offset = posx
            margin_l = offset
            margin_r = 2 * buffer - offset
        when "right"
            offset = posx - width
            margin_l = 2 * buffer + offset
            margin_r = -offset

    -- ensure line margins are non-zero (i.e. do not read from style)
    -- might possibly cause reflows in very edge cases!
    if margin_l == 0
        margin_l = -1
        margin_r -= 1
    if margin_r == 0
        margin_r = -1
        margin_l -= 1
    
    -- for clean-up: remove useless margin values
    if margin_l == line.styleref.margin_l then margin_l = 0
    if margin_r == line.styleref.margin_r then margin_r = 0

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

if havedc
    dep\registerMacro main, can_run
else
    aegisub.register_macro(script_name, script_description, main, can_run)
