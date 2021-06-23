export script_name = "Autowrapper"
export script_description = "Automatically set/unset \\q2 on lines with/without manual linebreaks"
export script_author = "petzku"
export script_namespace = "petzku.Autowrapper"
export script_version = "0.2.0"

havedc, DependencyControl, dep = pcall require, "l0.DependencyControl"
if havedc
    dep = DependencyControl{{'karaskel'}}
    dep\requireModules!
else
    require 'karaskel'

is_overwidth = (meta, line) ->
    -- maximum width of line before automatically wrapping
    wrap_width = meta.res_x - line.styleref.margin_l - line.styleref.margin_r
    line.width > wrap_width

main = (subs, _sel) ->
    meta, styles = karaskel.collect_head subs, false
    -- operate on all dialogue lines, not just selection
    -- maybe change this?
    res_addq2, res_autobreak, res_remq2 = 0,0,0
    for i, line in ipairs subs
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line subs, meta, styles, line

        if line.text_stripped\find '\\N'
            unless line.text\find '\\q2'
                line.text = '{\\q2}'..line.text
                res_addq2 += 1
        else
            if is_overwidth meta, line
                -- warn, do not add \q2
                line.effect ..= "## AUTOMATIC LINEBREAK ##"
                res_autobreak += 1
            else
                line.text = line.text\gsub '\\q2', ''
                -- and remove empty tag blocks, if we caused one
                line.text = line.text\gsub '{}', ''
                res_remq2 += 1
        subs[i] = line
    aegisub.set_undo_point "automatically set/unset \\q2"

    if res_addq2 > 0 then     aegisub.log "Added %d \\q2's on lines with \\N\n", res_addq2
    if res_autobreak > 0 then aegisub.log "Found %d automatic linebreaks\n", res_autobreak
    if res_remq2 > 0 then     aegisub.log "Removed %d \\q2's from lines without \\N\n", res_remq2

if havedc
    dep\registerMacro main
else
    aegisub.register_macro script_name, script_description, main
