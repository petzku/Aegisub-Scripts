export script_name = "Autowrapper"
export script_description = "Automatically set/unset \\q2 on lines with/without manual linebreaks"
export alt_description = "Automatically unset \\q2 on lines without manual linebreaks"
export script_author = "petzku"
export script_namespace = "petzku.Autowrapper"
export script_version = "0.5.1"

havedc, DependencyControl, dep = pcall require, "l0.DependencyControl"
if havedc
    dep = DependencyControl{
        feed: "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json",
        {'karaskel'}
    }
    dep\requireModules!
else
    require 'karaskel'

space_for_line = (meta, line) ->
    -- maximum width of line before automatically wrapping
    -- eff_margin takes into account in-line margins
    meta.res_x - line.eff_margin_l - line.eff_margin_r

lines_needed = (meta, line) ->
    -- calculate line length in terms of maximum wrapping width,
    -- i.e. a value under 1 means the line fits on one line,
    -- while a value over 2 means it needs _three_ lines to fit
    wrap_width = space_for_line meta, line
    line.width / wrap_width

length_ratio = (text, style) ->
    -- assuming the line contains a newline,
    -- calculate lengths of each half
    -- as well as the ratio of the two
    first, second = text\match "^%s*(.-)%s*\\N%s*(.-)%s*$"
    a, _ = aegisub.text_extents style, first
    b, _ = aegisub.text_extents style, second
    if a > b
        a / b, a, b
    else
        b / a, a, b


process = (subs, add_q2=true, rem_q2=true) ->
    -- operates on all dialogue lines, not just selection
    meta, styles = karaskel.collect_head subs, false

    res_addq2, res_autobreak, res_remq2 = 0,0,0
    res_overq2 = 0
    res_threelines, res_maybethree = 0, 0

    for i, line in ipairs subs
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line subs, meta, styles, line

        edit = false
        if line.text_stripped\find '\\N'
            if add_q2 and not line.text\find '\\q2'
                line.text = '{\\q2}'..line.text
                res_addq2 += 1
                edit = true
            if not add_q2
                -- check each half for potential two-liner
                _, top, bot = length_ratio line.text_stripped, line.styleref
                space = space_for_line meta, line
                if top > space or bot > space
                    line.effect ..= "## Likely three-liner with forced break ##"
                    res_threelines += 1
                    edit = true
        else
            lines = lines_needed meta, line
            if not line.text\find '\\q2'
                -- no manual newline, and default wrapping mode
                -- warn of automatic linebreaks, and flag three-liners separately
                if lines > 2
                    -- three-liner
                    line.effect ..= "## Three-liner ##"
                    res_threelines += 1
                    edit = true
                elseif lines > 1.9
                    -- maybe three-liner
                    line.effect ..= "## Possible three-liner ##"
                    res_maybethree += 1
                    edit = true
                elseif lines > 1
                    -- warn, do not add \q2
                    line.effect ..= "## Automatic linebreak ##"
                    res_autobreak += 1
                    edit = true
            else
                if lines > 1
                    -- overwidth but has \q2
                    line.effect ..= "## Overwidth with forced wrap ##"
                    res_overq2 += 1
                    edit = true
                elseif rem_q2
                    -- no newline and line is short enough to fit on one line
                    -- => it's safe to remove the \q2
                    line.text = line.text\gsub '\\q2', ''
                    -- and remove empty tag blocks, if we caused one
                    line.text = line.text\gsub '{}', ''
                    res_remq2 += 1
                    edit = true
        subs[i] = line if edit
    aegisub.set_undo_point "automatically set/unset \\q2"

    if res_addq2 > 0 then     aegisub.log "Added %d \\q2's on lines with \\N\n", res_addq2
    if res_autobreak > 0 then aegisub.log "Found %d automatic linebreaks\n", res_autobreak
    if res_threelines + res_maybethree > 0 then aegisub.log "Found %d three-liners and %d likely ones\n", res_threelines, res_maybethree
    if res_overq2 > 0 then    aegisub.log "Found %d overwidth lines with prevented wrapping\n", res_overq2
    if res_remq2 > 0 then     aegisub.log "Removed %d \\q2's from lines without \\N\n", res_remq2

balance = (line, no_checks=false) ->
    return unless line.text_stripped\match "\\N"

    ratio, top, bot = length_ratio line.text_stripped, line.styleref

    space = space_for_line meta, line
    spaceratio = math.max(top, bot) / space

    -- for selected lines
    if no_checks
        line.effect ..= string.format("## (%.2f ratio, %d%% width)", ratio, spaceratio*100)
        return line
    -- for file-scan
    edit = false
    if ratio > 1.5
        line.effect ..= string.format("## Notably lopsided line break (%.2f ratio) ##", ratio)
        edit = true
    if spaceratio < 0.4
        line.effect ..= string.format("## Unnecessary line break (%d%% width) ##", spaceratio*100)
        edit = true
    return line if edit


line_balance = (subs, _sel) ->
    meta, styles = karaskel.collect_head subs, false

    for i, line in ipairs subs
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line subs, meta, styles, line

        line = balance line

        subs[i] = line if line

scanline = (subs, sel) ->
    meta, styles = karaskel.collect_head subs, false

    for i in *sel
        line = subs[i]
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line subs, meta, styles, line
        line = balance line, true
        subs[i] = line


main = (subs, _sel) ->
    process subs

no_q2 = (subs, _sel) ->
    process subs, false

comment = (subs, _sel) ->
    process subs, false, false

macros = {
    { "Add missing \\q2 tags", script_description, main },
    { "Remove unnecessary \\q2 tags", alt_description, no_q2 },
    { "Only note automatic breaks", "", comment },
    { "Check line break visual balance", "", line_balance },
    { "Analyze selected lines' visual balance", "", select_balance },
}

if havedc
    dep\registerMacros macros
else
    for m in *macros
        name, desc, fun = unpack m
        aegisub.register_macro script_name..'/'..name, desc, fun
