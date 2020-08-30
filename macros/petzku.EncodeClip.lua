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

script_name = tr'Make clip'
script_description = tr'Encode a hardsubbed clip encompassing the current selection'
script_author = 'petzku'
script_namespace = "petzku.EncodeClip"
script_version = '0.2.0'

local DependencyControl = require("l0.DependencyControl")
local depctrl = DependencyControl{feed = "https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json"}

-- "\" on windows, "/" on any other system
local pathsep = package.config:sub(1,1)
local is_windows = pathsep == "\\"

function make_clip(subs, sel, _)
    local t1, t2 = math.huge, 0
	for _, i in ipairs(sel) do
		t1 = math.min(t1, subs[i].start_time)
		t2 = math.max(t2, subs[i].end_time)
	end
	local t1, t2 = t1/1000, t2/1000

	local props = aegisub.project_properties()
	local vidfile = props.video_file
	local subfile = aegisub.decode_path("?script") .. pathsep .. aegisub.file_name()
	--local outfile = vidfile:gsub('.m[kp][v4]$', '') .. ('_%.3f-%.3f'):format(t1, t2) .. '.mp4'
	local outfile = subfile:sub(1, -5) .. ('_%.3f-%.3f'):format(t1, t2) .. '.mp4'

    encode_clip(vidfile, subfile, t1, t2, outfile)
end

function encode_clip(vid, subs, t1, t2, out)
    -- TODO: allow arbitrary command line parameters from user
	local cmd = table.concat({
		'mpv', -- TODO: let user specify mpv location if not on PATH
		'--sub-font-provider=auto',
		'--start=%.3f',
		'--end=%.3f',
		'"%s"',
		'--sub-file="%s"',
		'--vf=format=yuv420p',
        '--o="%s"'
	}, ' '):format(t1, t2, vid, subs, out)
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

depctrl:registerMacro(make_clip)
