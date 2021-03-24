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

--[[ README

# Encode Clip

Uses mpv (executable *must* be on your PATH!) to encode a clip of the current selection.

Macros and GUI should be self-explanatory.

Video and audio are taken from the file(s) loaded into Aegisub, and subtitles from the active script.

I don't know of a way to get the currently active audio track's ID from Aegisub, so dual audio may not work correctly.
You can remedy this by specifying the audio track in the configuration dialog. For example:
`--aid=2` to select the second audio track, or `--alang=jpn` to select the first japanese audio track

]]

local tr = aegisub.gettext

script_name = tr'Encode Clip'
script_description = tr'Encode various clips from the current selection'
script_author = 'petzku'
script_namespace = "petzku.EncodeClip"
script_version = '0.6.0'


local haveDepCtrl, DependencyControl, depctrl = pcall(require, "l0.DependencyControl")
local ConfigHandler, config
if haveDepCtrl then
    depctrl = DependencyControl{
        {"a-mo.ConfigHandler", version="1.1.4", url="https://github.com/TypesettingTools/Aegisub-Motion",
         feed="https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"},
    }
    ConfigHandler = depctrl:requireModules()
end

local config_dialog = {
    main = {
        exe_label = {
            class='label', label="mpv path:",
            x=0, y=0, width=5, height=1
        },
        mpv_exe = {
            class='edit', value="", config=true,
            x=5, y=0, width=15, height=1,
            hint=[[Path to the mpv executable. If left blank, searches system PATH.]]
        },
        video_command_label = {
            class='label', label='Custom video clip options:',
            x=0, y=1, width=10, height=1
        },
        video_command = {
            class='textbox', value="--sub-font-provider=auto", config=true,
            x=0, y=2, width=20, height=3,
            hint=[[Custom command line options flags passed to mpv when encoding video. Default is "--sub-font-provider=auto", as many mpv configs set this to 'none' by default.]]
        },
        audio_command_label = {
            class='label', label='Custom audio clip options:',
            x=0, y=5, width=10, height=1
        },
        audio_command = {
            class='textbox', value="", config=true,
            x=0, y=6, width=20, height=3,
            hint=[[Custom command line options passed to mpv when encoding only audio.]]
        }
    }
}
if haveDepCtrl then
    config = ConfigHandler(config_dialog, depctrl.configFile, false, script_version, depctrl.configDir)
    config:read()
    config:updateInterface("main")
end

local function get_configuration()
    -- this seems hacky, maybe use depctrl's confighandler instead
    local opts = {}
    for key, values in ipairs(config_dialog.main) do
        if values.config then
            opts[key] = values.value
        end
    end
    return opts
end

-- "\" on windows, "/" on any other system
local pathsep = package.config:sub(1,1)
local is_windows = pathsep == "\\"

-- find the best AAC encoder available to us, since ffmpeg-internal is Bad
-- mpv *should* support --oac="aac_at,aac_mf,libfdk_aac,aac", but it doesn't so we do this
local aac_encoder = nil
local function best_aac_encoder()
    if aac_encoder ~= nil then
        return aac_encoder
    end
    local priorities = {aac = 0, libfdk_aac = 1, aac_mf = 2, aac_at = 3}
    local best = "aac"
    for line in run_cmd("mpv --oac=help", true):gmatch("[^\r\n]+") do
        local enc = line:match("--oac=(%S*aac%S*)")
        if enc and priorities[enc] and priorities[enc] > priorities[best] then
            best = enc
        end
    end
    aac_encoder = best
    return best
end

local function calc_start_end(subs, sel)
    local t1, t2 = math.huge, 0
    for _, i in ipairs(sel) do
        t1 = math.min(t1, subs[i].start_time)
        t2 = math.max(t2, subs[i].end_time)
    end
    return t1/1000, t2/1000
end

function make_clip(subs, sel, hardsub, audio)
    if audio == nil then audio = true end --encode with audio by default

    local t1, t2 = calc_start_end(subs, sel)

    local props = aegisub.project_properties()
    local vidfile = props.video_file
    local subfile = aegisub.decode_path("?script") .. pathsep .. aegisub.file_name()

    local outfile
    if aegisub.decode_path("?script") == "?script" then
        -- no script file to work with, save next to source video instead
        outfile = vidfile
        hardsub = false
    else
        outfile = subfile
    end
    outfile = outfile:gsub('%.[^.]+$', '') .. ('_%.3f-%.3f'):format(t1, t2) .. '%s.mp4'

    local postfix = ""

    local audio_opts
    if audio then
        audio_opts = table.concat({
            '--oac=' .. best_aac_encoder(),
            '--oacopts="b=256k,frame_size=1024"'
        }, ' ')
    else
        audio_opts = '--audio=no'
        postfix = postfix .. "_noaudio"
    end

    local sub_opts
    if hardsub then
        sub_opts = table.concat({
            '--sub-font-provider=auto',
            '--sub-file="%s"'
        }, ' '):format(subfile)
    else
        sub_opts = '--sid=no'
        postfix = postfix .. "_nosub"
    end

    local user_opts = get_configuration()
    local mpv_exe
    if user_opts.mpv_exe and user_opts.mpv_exe ~= '' then
        mpv_exe = user_opts.mpv_exe
    else
        mpv_exe = 'mpv'
    end

    local commands = {
        mpv_exe,
        '--start=%.3f',
        '--end=%.3f',
        '"%s"',
        '--vf=format=yuv420p',
        '--o="%s"',
        '--ovcopts="profile=main,level=4.1,crf=23"',
        audio_opts,
        sub_opts,
        user_opts.video_command
    }

    outfile = outfile:format(postfix)
    local cmd = table.concat(commands, ' '):format(t1, t2, vidfile, outfile)
    run_cmd(cmd)
end

function make_audio_clip(subs, sel)
    local t1, t2 = calc_start_end(subs, sel)

    local props = aegisub.project_properties()
    local vidfile = props.video_file

    local outfile
    if aegisub.decode_path("?script") == "?script" then
        outfile = vidfile
    else
        outfile = aegisub.decode_path("?script") .. pathsep .. aegisub.file_name()
    end
    outfile = outfile:gsub('%.[^.]+$', '') .. ('_%.3f-%.3f'):format(t1, t2) .. '.aac'

    local user_opts = get_configuration()
    local mpv_exe
    if user_opts.mpv_exe and user_opts.mpv_exe ~= '' then
        mpv_exe = user_opts.mpv_exe
    else
        mpv_exe = 'mpv'
    end

    local commands = {
        mpv_exe,
        '--start=%.3f',
        '--end=%.3f',
        '"%s"',
        '--video=no',
        '--o="%s"',
        '--oac=' .. best_aac_encoder(),
        '--oacopts="b=256k,frame_size=1024"',
        user_opts.audio_command
    }

    local cmd = table.concat(commands, ' '):format(t1, t2, vidfile, outfile)
    run_cmd(cmd)
end

function run_cmd(cmd, quiet)
    if not quiet then
        aegisub.log('running: ' .. cmd .. '\n')
    end

    local output
    if is_windows then
        -- command lines over 256 bytes don't get run correctly, make a temporary file as a workaround
        local tmp = aegisub.decode_path('?temp' .. pathsep .. 'tmp.bat')
        local f = io.open(tmp, 'w')
        f:write(cmd)
        f:close()

        local p = io.popen(tmp)
        output = p:read('*a')
        if not quiet then
            aegisub.log(output)
        end
        p:close()

        os.execute('del ' .. tmp)
    else
        -- on linux, we should be fine to just execute the command directly
        local p = io.popen(cmd)
        output = p:read('*a')
        if not quiet then
            aegisub.log(output)
        end
        p:close()
    end
    return output
end

function show_dialog(subs, sel)
    local VIDEO = tr"&Video clip"
    local AUDIO = tr"Audio-&only clip"
    local CONFIG = tr"Confi&g"
    local diag = {
        {class = 'label', x=0, y=0, label = tr"Settings for video clip: "},
        {class = 'checkbox', x=1, y=0, label = tr"&Subs", hint = tr"Enable subtitles in output", name = 'subs', value = true},
        {class = 'checkbox', x=2, y=0, label = tr"&Audio", hint = tr"Enable audio in output", name = 'audio', value = true}
    }
    local buttons
    if haveDepCtrl then
        buttons = {AUDIO, VIDEO, CONFIG, tr"&Cancel"}
    else
        buttons = {AUDIO, VIDEO, tr"&Cancel"}
    end
    local btn, values = aegisub.dialog.display(diag, buttons, {cancel=tr"&Cancel"})

    if btn == AUDIO then
        make_audio_clip(subs, sel)
    elseif btn == VIDEO then
        make_clip(subs, sel, values['subs'], values['audio'])
    elseif btn == CONFIG then
        show_config_dialog()
        -- once config is done, re-open this dialog
        show_dialog(subs, sel)
    end
end

function show_config_dialog()
    local button, result = aegisub.dialog.display(config_dialog.main)
    if button then
        config:updateConfiguration(result, 'main')
        config:write()
        config:updateInterface("main")
    end
end

function make_hardsub_clip(subs, sel, _)
    make_clip(subs, sel, true, true)
end

function make_raw_clip(subs, sel, _)
    make_clip(subs, sel, false, true)
end

function make_hardsub_clip_muted(subs, sel, _)
    make_clip(subs, sel, true, false)
end

function make_raw_clip_muted(subs, sel, _)
    make_clip(subs, sel, false, false)
end

local macros = {
    {tr'Clip with subtitles',   tr'Encode a hardsubbed clip encompassing the current selection', make_hardsub_clip},
    {tr'Clip raw video',        tr'Encode a clip encompassing the current selection, but without subtitles', make_raw_clip},
    {tr'Clip with subtitles (no audio)',tr'Encode a hardsubbed clip encompassing the current selection, but without audio', make_hardsub_clip_muted},
    {tr'Clip raw video (no audio)',     tr'Encode a clip encompassing the current selection of the video only', make_raw_clip_muted},
    {tr'Clip audio only',       tr'Clip just the audio for the selection', make_audio_clip},
    {tr'Clipping GUI',          tr'GUI for all your video/audio clipping needs', show_dialog}
}
if haveDepCtrl then
    -- configuration support for depctrl only
    table.insert(macros, {tr'Config', tr'Open configuration menu', show_config_dialog})
    depctrl:registerMacros(macros)
else
    for i,macro in ipairs(macros) do
        local name, desc, fun = unpack(macro)
        aegisub.register_macro(script_name .. '/' .. name, desc, fun)
    end
end
