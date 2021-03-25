main = (subs, sel) ->
    start = sel[1]
    for i = start, #subs
        table.insert sel, i
    table.insert sel, start
    sel

aegisub.register_macro "selection hack", "select all lines from current to file end", main
