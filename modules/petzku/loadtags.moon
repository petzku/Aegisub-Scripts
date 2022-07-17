-- Copyright (c) 2022 petzku <petzku@zku.fi>

-- Load colon-separated tag-value pairs from a line's actor field.
-- Transforms semicolons into commas because of aegisub limitations. Not much to be done there, unfortunately.

-- Takes in either a line table, or a raw string. If passed a line table, reads from the actor field.
-- General usage (assuming "foo=3:bar=4" in actor field):
--  loadtags.str(line)      -> "\foo3\bar4"
--  loadtags.table(line)    -> {foo: "3", bar: "4"}
--  loadtags.table("foo=3") -> {foo: "3"}

tags_table = (line) ->
    if type(line) == "table" then line = line.actor
    t = {}
    for tag, value in line\gmatch "(%w+)=([^:]+)"
        if tag then
            value = value\gsub ";", ","
            t[tag] = value
    return t

tag_string = (line) ->
    if type(line) == "table" then line = line.actor
    out = ""
    -- loop through string manually because table loses ordering
    for tag, value in line\gmatch "(%w+)=([^:]+)"
        if tag then
            value = value\gsub ";", ","
            out ..= "\\" .. tag .. value
    return out

return {
    table: tags_table,
    str: tag_string
}
