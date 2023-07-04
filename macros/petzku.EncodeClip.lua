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

Uses mpv to encode a clip of the current selection.
The mpv executable *must* be either on your PATH, or specified in the configuration dialog!

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
script_version = '0.8.4'


local haveDepCtrl, DependencyControl, depctrl = pcall(require, "l0.DependencyControl")
local ConfigHandler, config, petzku
if haveDepCtrl then
    depctrl = DependencyControl {
        feed="https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json",
        {
            {"petzku.util", version="0.3.0", url="https://github.com/petzku/Aegisub-Scripts",
             feed="https://raw.githubusercontent.com/petzku/Aegisub-Scripts/stable/DependencyControl.json"},
            {"a-mo.ConfigHandler", version="1.1.4", url="https://github.com/TypesettingTools/Aegisub-Motion",
             feed="https://raw.githubusercontent.com/TypesettingTools/Aegisub-Motion/DepCtrl/DependencyControl.json"}
        }
    }
    petzku, ConfigHandler = depctrl:requireModules()
else
    petzku = require 'petzku.util'
end

local config_diag = {
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
            class='label', label='Custom mpv options for video clips:',
            x=0, y=1, width=10, height=1
        },
        video_command = {
            class='textbox', value="--sub-font-provider=auto", config=true,
            x=0, y=2, width=20, height=3,
            hint=[[Custom command line options flags passed to mpv when encoding video. Default is "--sub-font-provider=auto", as many mpv configs set this to 'none' by default.]]
        },
        audio_encoder_label = {
            class='label', label='Audio encoder. Defaults to best available AAC.',
            x=0, y=5, width=5, height=1
        },
        audio_encoder = {
            class='edit', value="", config=true,
            x=5, y=5, width=15, height=1,
            hint="Audio encoder to use. If left blank, automatically picks the best available AAC encoder.\nNote that you may need to change --oacopts if you use a non-AAC encoder."
        },
        audio_command_label = {
            class='label', label='Custom mpv options for audio-only clips:',
            x=0, y=6, width=10, height=1
        },
        audio_command = {
            class='textbox', value="", config=true,
            x=0, y=7, width=20, height=3,
            hint=[[Custom command line options passed to mpv when encoding only audio.]]
        }
    }
}
local GUI = {
    main = {
        settings_label = {
            class='label', label=tr"Settings for video clip: ",
            x=0, y=0
        },
        subs = {
            class='checkbox', label=tr"&Subs", value=true, name='subs',
            x=1, y=0,
            hint=tr[[Enable subtitles in output]]
        },
        audio = {
            class='checkbox', label=tr"&Audio", value=true, name='audio',
            x=2, y=0,
            hint=tr[[Enable audio in output]]
        }
    },
    -- constants for the buttons
    BUTTONS = {
        AUDIO = tr"Audio-&only clip",
        VIDEO = tr"&Video clip",
        CONFIG = tr"Confi&g",
        CANCEL = tr"&Cancel"
    },
    show_user_warning = function(title, desc, proceed)
        return aegisub.dialog.display(
            {
                {class="label", label=title, x=0, y=0},
                {class="label", label=desc, x=0, y=1}
            },
            {proceed, "&Cancel"},
            {ok = proceed, cancel = "&Cancel"}
        )
    end
}
if haveDepCtrl then
    config = ConfigHandler(config_diag, depctrl.configFile, false, script_version, depctrl.configDir)
end

local function get_configuration()
    if haveDepCtrl then
        config:read()
        config:updateInterface("main")
    end
    -- this seems hacky, maybe use depctrl's confighandler instead
    local opts = {}
    for key, values in pairs(config_diag.main) do
        if values.config then
            opts[key] = values.value
        end
    end
    return opts
end

-- Use user-specified encoder, if one exists.
-- Otherwise, find the best AAC encoder available to us, since ffmpeg-internal is Bad
-- mpv *should* support --oac="aac_at,aac_mf,libfdk_aac,aac", but it doesn't so we do this
local audio_encoder = nil
local function get_audio_encoder()
    if audio_encoder ~= nil then
        return audio_encoder
    end

    local opt = get_configuration()
    if opt.audio_encoder and opt.audio_encoder ~= "" then
        return opt.audio_encoder
    end

    local priorities = {aac = 0, libfdk_aac = 1, aac_mf = 2, aac_at = 3}
    local best = "aac"
    for line in petzku.io.run_cmd("mpv --oac=help", true):gmatch("[^\r\n]+") do
        local enc = line:match("--oac=(%S*aac%S*)")
        if enc and priorities[enc] and priorities[enc] > priorities[best] then
            best = enc
        end
    end
    audio_encoder = best
    return best
end

local function get_mpv()
    local user_opts = get_configuration()
    local mpv_exe
    if user_opts.mpv_exe and user_opts.mpv_exe ~= '' then
        mpv_exe = user_opts.mpv_exe
        if mpv_exe:match(" ") and not mpv_exe:match("['\"]") then
            -- spaces but no quotes
            mpv_exe = '"'..mpv_exe..'"'
        end
    else
        mpv_exe = 'mpv'
    end
    return mpv_exe
end

local function get_base_outfile(t1, t2, ext)
    local outfile, cant_hardsub
    if aegisub.decode_path("?script") == "?script" then
        -- no script file to work with, save next to source video instead
        outfile = aegisub.project_properties().video_file
        cant_hardsub = true
    else
        outfile = aegisub.decode_path("?script") .. petzku.io.pathsep .. aegisub.file_name()
    end
    outfile = outfile:gsub('%.[^.]+$', '') .. string.format('_%.3f-%.3f', t1, t2) .. '.' .. ext

    return outfile, cant_hardsub
end

local function calc_start_end(subs, sel)
    local t1, t2 = math.huge, 0
    for _, i in ipairs(sel) do
        t1 = math.min(t1, subs[i].start_time)
        t2 = math.max(t2, subs[i].end_time)
    end
    return t1/1000, t2/1000
end

local function is_ascii(str)
    for i=1, #str do
        if str:byte(i) > 128 then
            return false
        end
    end
    return true
end

local function run_cmd(cmd)
    -- run the encode command, alerting with possible fixes in the case of an error
    local output = petzku.io.run_cmd(cmd)

    local WINDOWS_ASCII_ERROR_TEXT = "No such file or directory"
    if output:find(WINDOWS_ASCII_ERROR_TEXT) and not is_ascii(cmd) then
        aegisub.log(2, "\nIt looks like some of your input or output file names contain non-ASCII characters, which can break on some systems.\n")
        aegisub.log(2, "Setting your system to use UTF-8 codepages may solve this issue; see https://superuser.com/a/1451686.\n\n")
    end
end

function make_clip(subs, sel, hardsub, audio)
    if audio == nil then audio = true end --encode with audio by default

    local t1, t2 = calc_start_end(subs, sel)

    local props = aegisub.project_properties()
    local vidfile = props.video_file
    local subfile = aegisub.decode_path("?script") .. petzku.io.pathsep .. aegisub.file_name()

    local outfile, cant_hardsub = get_base_outfile(t1, t2, 'mp4')
    if cant_hardsub then hardsub = false end

    if hardsub and aegisub.gui and aegisub.gui.is_modified and aegisub.gui.is_modified() then
        -- warn user about script not being saved
        if not GUI.show_user_warning("File not saved!", [[Current script file has not been saved.
        You probably wanted to save first.
        Press Enter to proceed anyway, or Escape to cancel.]], "Encode &anyway") then
            return
        end
    end

    local postfix = ""

    local audio_opts
    if audio then
        -- If audio is not loaded, this property is blank (an empty string).
        -- We assume the user is more likely to want audio from the video file than none at all, if they requested a clip with audio.
        local audiofile = props.audio_file ~= "" and props.audio_file or props.video_file

        local _opts = {
            '--oac=' .. get_audio_encoder(),
            '--oacopts="b=256k,frame_size=1024"'
        }
        if audiofile ~= vidfile then
            table.insert(_opts, string.format('--audio-file="%s"', audiofile))
        end
        audio_opts = table.concat(_opts, ' ')
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
    local mpv_exe = get_mpv()

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

    if postfix ~= '' then
        outfile = outfile:sub(1, -5) .. postfix .. '.mp4'
    end
    local cmd = table.concat(commands, ' '):format(t1, t2, vidfile, outfile)
    run_cmd(cmd)
end

function make_audio_clip(subs, sel)
    local t1, t2 = calc_start_end(subs, sel)

    local props = aegisub.project_properties()
    local audiofile = props.audio_file

    local outfile = get_base_outfile(t1, t2, 'm4a')

    local user_opts = get_configuration()
    local mpv_exe = get_mpv()

    local commands = {
        mpv_exe,
        '--start=%.3f',
        '--end=%.3f',
        '"%s"',
        '--video=no',
        '--o="%s"',
        '--oac=' .. get_audio_encoder(),
        '--oacopts="b=256k,frame_size=1024"',
        user_opts.audio_command
    }

    local cmd = table.concat(commands, ' '):format(t1, t2, audiofile, outfile)
    run_cmd(cmd)
end

function show_dialog(subs, sel)
    local buttons = haveDepCtrl and {
        GUI.BUTTONS.AUDIO, GUI.BUTTONS.VIDEO, GUI.BUTTONS.CONFIG, GUI.BUTTONS.CANCEL
    } or {
        GUI.BUTTONS.AUDIO, GUI.BUTTONS.VIDEO, GUI.BUTTONS.CANCEL
    }
    local btn, values = aegisub.dialog.display(GUI.main, buttons, {ok=GUI.BUTTONS.VIDEO, cancel=GUI.BUTTONS.CANCEL})

    if btn == GUI.BUTTONS.AUDIO then
        make_audio_clip(subs, sel)
    elseif btn == GUI.BUTTONS.VIDEO then
        make_clip(subs, sel, values.subs, values.audio)
    elseif btn == GUI.BUTTONS.CONFIG then
        show_config_dialog()
        -- once config is done, re-open this dialog
        show_dialog(subs, sel)
    end
end

function show_config_dialog()
    config:read()
    config:updateInterface("main")
    local button, result = aegisub.dialog.display(config_diag.main)
    if button then
        config:updateConfiguration(result, 'main')
        config:write()
        config:updateInterface('main')
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
    for _,macro in ipairs(macros) do
        local name, desc, fun = unpack(macro)
        aegisub.register_macro(script_name .. '/' .. name, desc, fun)
    end
end
