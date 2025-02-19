script_name = "Toggle Templates"
script_description = "Toggle disabled state for selected auto4 ktemplate components"
script_author = "petzku"
script_version = "0.3.1"
script_namespace = "petzku.ToggleTemplates"

is_component = (line) ->
    return false unless line.class == "dialogue" and line.comment
    cls = line.effect\match "(%l+) "
    -- assume anything marked "disabled" is also fair game
    return cls == 'disabled' or cls == 'template' or cls == 'code' or cls == 'mixin'

is_disabled = (line) ->
    return 'disabled' == line.effect\sub 1, 8

main = (sub, sel) ->
    for i in *sel
        line = sub[i]
        continue unless is_component line
        if is_disabled line
            line.effect = line.effect\sub 10
        else
            line.effect = 'disabled ' .. line.effect
        sub[i] = line

can_run = (sub, sel) ->
    for i in *sel
        return true if is_component sub[i]
    return false

aegisub.register_macro script_name, script_description, main
