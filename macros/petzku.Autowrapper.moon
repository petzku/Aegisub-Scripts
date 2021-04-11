export script_name = "Autowrapper"
export script_description = "Automatically set/unset \\q2 on lines with/without manual linebreaks"
export script_author = "petzku"
export script_namespace = "petzku.Autowrapper"
export script_version = "0.1.0"

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
    for i, line in ipairs subs
        continue unless line.class == 'dialogue' and not line.comment
        karaskel.preproc_line subs, meta, styles, line

        if line.text_stripped\find '\\N'
            unless line.text\find '\\q2'
                line.text = '{\\q2}'..line.text
        else
            if is_overwidth meta, line
                -- warn, do not add \q2
                line.effect ..= "## AUTOMATIC LINEBREAK ##"
            else
                line.text = line.text\gsub '\\q2', ''
                -- and remove empty tag blocks, if we caused one
                line.text = line.text\gsub '{}', ''
        subs[i] = line
    aegisub.set_undo_point "automatically set/unset \\q2"

if havedc
    depctrl\registerMacro main
else
    aegisub.register_macro script_name, script_description, main
