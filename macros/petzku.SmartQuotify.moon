export script_name = "SmartQuotify"
export script_description = [[Change all your "normal" quotes into “smart” ones]]
export script_author = "petzku"
export script_namespace = "petzku.SmartQuotify"
export script_version = "0.2.2"

re = require 'aegisub.re'

main = =>
    for i, line in ipairs @
        continue unless line.class == "dialogue" and not line.comment
        aegisub.log(5, "dialogue line: %s\n", line.text)

        continue unless line.text\find "['\"]"
        aegisub.log(5, "... has quotes\n")

        -- to explain the regex, most importantly *this mess*
        --      (?:(?<!\w)|(?<=\\[Nnh]))
        -- it basically checks "is there whitespace before this quote":
        --      (?:                    )        non-capturing group
        --                |                       which accepts either
        --         (?<!  )                          a negative lookbehind
        --             \w                             declining any word characters
        --                 (?<=       )             a positive lookbehind
        --                     \\[Nnh]                accepting any of \N, \n, \h
        --
        -- also, these (albeit much simpler) regexes (regices? regrets?) check for
        -- any number of quote characters between the current symbol and the start of the word,
        -- therefore matching stuff like nested quotes or: He said "'tis but a flesh wound!".
        --      (?=['"]*\w) and (?=[‘’"]*\w)

        -- Apostrophes are always supposed to be right quotes, even at the start of a word.
        -- This makes converting them correctly impossible without NLP, as this can't be distinguished from a starting single quote.
        -- Instead, we leave the user a warning and have them check it themself.
        text, apos_found = re.sub line.text, [[(?:(?<!\w)|(?<=\\[Nnh]))'(?=\w)]], "’"

        -- We can, however, assume that any cases where another quotation mark appears between the quote and the word, it's not an apostrophe.
        text = re.sub text, [[(?:(?<!\w)|(?<=\\[Nnh]))'(?=['"]+\w)]], "‘"
        text = re.sub text, "'", "’"

        -- First, we replace any pairs of double quotes.
        -- This _will_ break triply nested quotes, but those are very rare, so we can probably ignore that.
        text = re.sub text, [["(.+?)"]], [[“\1”]]

        -- Then, we handle any remaining, unpaired double-quotes heuristically.
        -- This could be e.g. quotes extending over two (or more) lines.

        -- Simply put, we assume any quote directly before a word
        -- (but not in the middle of one, i.e. must have whitespace before it) is opening,
        text = re.sub text, [[(?:(?<!\w)|(?<=\\[Nnh]))"(?=[‘’"]*\w)]], "“"
        -- and everything else is closing.
        text = re.sub text, '"', "”"

        -- Once we're all done, write into the line.
        line.text = text

        -- replacement count for apostrophe pattern
        if apos_found > 0
            line.effect ..= "[check possible starting single quote#{apos_found > 1 and 's' or ''} -- assumed apostrophe]"

        aegisub.log(5, "... is now %s\n", line.text)
        @[i] = line

aegisub.register_macro script_name, script_description, main
