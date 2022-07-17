-- load tags from the actor field, either into a table, or into a string

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
