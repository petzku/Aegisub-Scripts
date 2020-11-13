-- Copyright (c) 2020, petzku <petzku@zku.fi>
-- Copyright (c) 2020, The0x539 <the0x539@gmail.com>
--
-- Permission to use, copy, modify, and distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED 'AS IS' AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

local tr = aegisub.gettext

script_name = tr'Encode Clip'
script_description = tr'Encode a hardsubbed clip encompassing the current selection'
script_author = 'petzku'
script_namespace = "petzku.EncodeClip"
script_version = '0.3.4'


local haveDepCtrl, DependencyControl, depctrl = pcall(require, "l0.DependencyControl")
if haveDepCtrl then
    depctrl = DependencyControl{feed = "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json"}
end

-- "\" on windows, "/" on any other system
local pathsep = package.config:sub(1,1)
local is_windows = pathsep == "\\"

function make_clip(subs, sel, hardsub)
    local t1, t2 = math.huge, 0
    for _, i in ipairs(sel) do
        t1 = math.min(t1, subs[i].start_time)
        t2 = math.max(t2, subs[i].end_time)
    end
    local t1, t2 = t1/1000, t2/1000

    local props = aegisub.project_properties()
    local vidfile = props.video_file
    local subfile = aegisub.decode_path("?script") .. pathsep .. aegisub.file_name()

    local outfile
    if aegisub.decode_path("?script") == "?script" then
        -- no script file to work with, save next to source video instead
        outfile = vidfile:gsub('%.[^.]+$', '') .. ('_%.3f-%.3f'):format(t1, t2) .. '.mp4'
        hardsub = false
    else
        outfile = subfile:gsub('%.[^.]+$', '') .. ('_%.3f-%.3f'):format(t1, t2) .. '.mp4'
    end

    -- TODO: allow arbitrary command line parameters from user
    local commands = {
        'mpv', -- TODO: let user specify mpv location if not on PATH
        '--sub-font-provider=auto',
        '--start=%.3f',
        '--end=%.3f',
        '"%s"',
        '--vf=format=yuv420p',
        '--o="%s"',
        '--ovcopts="profile=main,level=4.1,crf=23"',
        '--oac=aac',
        '--oacopts="b=256k,frame_size=1024"'
    }

    local cmd
    if hardsub then
        table.insert(commands, '--sub-file="%s"')
        cmd = table.concat(commands, ' '):format(t1, t2, vidfile, outfile, subfile)
    else
        table.insert(commands, '--sid=no')
        outfile = outfile:sub(1, -5) .. "_raw.mp4"
        cmd = table.concat(commands, ' '):format(t1, t2, vidfile, outfile)
    end
    run_cmd(cmd)
end

function run_cmd(cmd)
    aegisub.log('running: ' .. cmd .. '\n')

    if is_windows then
        -- command lines over 256 bytes don't get run correctly, make a temporary file as a workaround
        local tmp = aegisub.decode_path('?temp' .. pathsep .. 'tmp.bat')
        local f = io.open(tmp, 'w')
        f:write(cmd)
        f:close()

        local p = io.popen(tmp)
        local output = p:read('*a')
        aegisub.log(output)
        p:close()

        os.execute('del ' .. tmp)
    else
        -- on linux, we should be fine to just execute the command directly
        local p = io.popen(cmd)
        local output = p:read('*a')
        aegisub.log(output)
        p:close()
    end
end

function make_hardsub_clip(subs, sel, _)
    make_clip(subs, sel, true)
end

function make_raw_clip(subs, sel, _)
    make_clip(subs, sel, false)
end

local macros = {
    {tr'Clip with subtitles', script_description, make_clip},
    {tr'Clip raw video', tr'Encode a clip encompassing the current selection, but without subtitles', make_raw_clip}
}
if haveDepCtrl then
    depctrl:registerMacros(macros)
else
    for i,macro in ipairs(macros) do
        local name, desc, fun = unpack(macro)
        aegisub.register_macro(script_name .. '/' .. name, desc, fun)
    end
end
