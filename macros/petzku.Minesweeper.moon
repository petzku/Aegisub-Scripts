-- Copyright (c) 2023 petzku <petzku@zku.fi>

export script_name =        "Minesweeper"
export script_description = "Play Minesweeper. Why? Who knows."
export script_author =      "petzku"
export script_namespace =   "petzku.Minesweeper"
export script_version =     "0.2.0"

WIDTH = 8
HEIGHT = 8
MAXMINES = 10

math.randomseed(os.time())

_rev = (field, x, y) ->
    tile = field[x][y]
    return unless tile.hidden
    tile.hidden = false
    if tile.n == 0 and not tile.mine
        -- cascade
        for i = -1,1
            for j = -1,1
                continue if i == 0 and j == 0
                xx = x + i
                yy = y + j
                continue if xx < 1 or yy < 1 or xx > WIDTH or yy > HEIGHT
                _rev field, xx, yy

build_field = ->
    t = {}
    for i = 1,WIDTH
        table.insert t, {}
        for j = 1,HEIGHT
            table.insert t[i], {hidden: true, mine: false, n: 0}

    -- place mines
    m = 0
    while m < MAXMINES
        x = math.random 1, WIDTH
        y = math.random 1, HEIGHT
        continue if t[x][y].mine
        m += 1
        t[x][y].mine = true
        for i = -1,1
            for j = -1,1
                continue if i == 0 and j == 0
                xx = x + i
                yy = y + j
                continue if xx < 1 or yy < 1 or xx > WIDTH or yy > HEIGHT
                t[xx][yy].n += 1

    -- reveal starting square
    while true
        x = math.random 1, WIDTH
        y = math.random 1, HEIGHT
        continue if t[x][y].mine
        _rev t, x, y
        break
    t

build_gui = (field, reveal) ->
    t = unless reveal
        {{x: 0, y: 0, height: 1, width: 10, class: "label", label: "Let's play minesweeper!"}}
    else
        {{x: 0, y: 0, height: 1, width: 10, class: "label", label: reveal}}
    for c, col in ipairs field
        for r, cell in ipairs col
            x = if cell.hidden
                unless reveal
                    {x: c, y: r, height: 1, width: 1, class: "checkbox", value: false, name: "#{c}-#{r}", hint: "#{c}-#{r}"}
                else
                    {x: c, y: r, height: 1, width: 1, class: "label", label: cell.mine and "💣" or " - "}
            else
                {x: c, y: r, height: 1, width: 1, class: "label", label: cell.mine and "💥" or "#{cell.n == 0 and '  ' or string.format "%2d ", cell.n}"}
            table.insert t, x
    t

reveal = (field, res) ->
    cells = {}
    for k, v in pairs res
        if v
            table.insert cells, k
    return field, true, "Open at least once cell!" unless #cells > 0
    -- try to open cell
    boom = false
    for cell in *cells
        x, y = cell\match "(%d+)%-(%d+)"
        x = tonumber x
        y = tonumber y

        -- we might have cascaded into this cell
        continue unless field[x][y].hidden
        aegisub.log 5, "revealing #{x},#{y}\n"

        -- reveal, cascading if this is zero
        _rev field, x, y
        boom or= field[x][y].mine
    field, not boom

check_win = (field) ->
    for col in *field
        for x in *col
            return false if x.hidden and not x.mine
    return true

main = () ->
    f = build_field!
    win = false
    while not win
        btn, res = aegisub.dialog.display build_gui f
        -- cancel = quit game
        break unless btn
        f, cont, msg = reveal f, res
        aegisub.log 3, msg if msg
        break unless cont

        win = check_win f
    aegisub.dialog.display build_gui f, win and "You won!" or "You lost!"

aegisub.register_macro script_name, script_description, main
