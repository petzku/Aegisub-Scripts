-- Copyright (c) 2022, petzku <petzku@zku.fi>

export script_name =        "Code Newliner"
export script_description = "Toggles semicolons in code lines to \\n's and back"
export script_author =      "petzku"
export script_namespace =   "petzku.CodeNewliner"
export script_version =     "1.0.0"


is_code_line = (line) ->
    return line.class == "dialogue" and line.comment and "code" == line.effect\sub 1,4


semicolon_to_newline = (line) ->
    line.text = line.text\gsub ";", "\n"
    line

newline_to_semicolon = (line) ->
    line.text = line.text\gsub "\n", ";"
    line

toggle = (line) ->
    if line.text\match "\n"
        newline_to_semicolon line
    else
        semicolon_to_newline line


process = (proc, sub) ->
    for i, line in ipairs sub
        if is_code_line line
            sub[i] = proc line


all_to_newline = (sub) ->
    process semicolon_to_newline, sub

all_to_semicolon = (sub) ->
    process newline_to_semicolon, sub

all_toggle = (sub) ->
    process toggle, sub


has_code_lines = (sub) ->
    for line in *sub
        if is_code_line line
            return true


aegisub.register_macro script_name.."/Toggle", "Toggle between newlines and semicolons on all code lines", all_toggle, has_code_lines
aegisub.register_macro script_name.."/Use newlines", "Switch all code lines to use newlines", all_to_newline, has_code_lines
aegisub.register_macro script_name.."/Use semicolons", "Switch all code lines to use semicolons", all_to_semicolon, has_code_lines
