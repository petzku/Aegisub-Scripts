export script_name = "SmartQuotify"
export script_description = [[Change all your "normal" quotes into “smart” ones]]
export script_author = "petzku"
export script_namespace = "petzku.SmartQuotify"
export script_version = "0.0.1"

re = require 'aegisub.re'

main = =>
    for i, line in ipairs @
        continue unless line.class == "dialogue" and not line.comment
        aegisub.log(5, "dialogue line: %s\n", line.text)

        continue unless line.text\find "['\"]"
        aegisub.log(5, "... has quotes\n")

        -- apostrophes are always supposed to be right quotes. this makes converting them correctly impossible without NLP.
        -- however, it's much simpler to just have the user check any lines that end up with left quotes themself.
        lsquote = re.sub line.text, [[(?<!\w)'(?=['"]*\w)]], "‘"
        rsquote = re.sub lsquote, "'", "’"
        ldquote = re.sub rsquote, [[(?<!\w)"(?=[‘"]*\w)]], "“"
        rdquote = re.sub ldquote, '"', "”"
        line.text = rdquote

        if line.text\find "‘"
            line.effect ..= "[check single quote -- possible apostrophe]"

        aegisub.log(5, "... is now %s\n", line.text)
        @[i] = line

aegisub.register_macro script_name, script_description, main