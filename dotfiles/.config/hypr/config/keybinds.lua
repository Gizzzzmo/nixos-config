-- Keybindings. See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

-- Launch applications
hl.bind(mainMod .. " + SHIFT + Q",  hl.dsp.exec_cmd([[ghostty_wrap -e bash -c "tmux-select-session-fzf; $SHELL"]]))
hl.bind(mainMod .. " + M",          hl.dsp.exec_cmd("tmux at -t cmux"))
hl.bind(mainMod .. " + Q",          hl.dsp.exec_cmd("ghostty_wrap"))
hl.bind(mainMod .. " + CTRL + Q",   hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + C",          hl.dsp.window.kill())
hl.bind(mainMod .. " + S",          hl.dsp.exec_cmd("steam"))
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd("nemo"))
hl.bind(mainMod .. " + A",          hl.dsp.exec_cmd("pw-jack ardour9"))
hl.bind(mainMod .. " + V",          hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",          hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. " + P",          hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + B",  hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd("qutebrowser"))
hl.bind(mainMod .. " + D",          hl.dsp.exec_cmd("discord --ozone-platform=wayland"))

-- Multimedia keys (locked = layer-shell, i.e. old bindl)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"),            { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"),            { locked = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"),              { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("cmus-control play-pause"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("cmus-control play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("cmus-control next"),       { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("cmus-control prev"),       { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("xbacklight -inc 5"),       { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("xbacklight -dec 5"),      { locked = true })

-- Miscellaneous launches / actions
hl.bind(mainMod .. " + XF86AudioPlay", hl.dsp.exec_cmd("cmus-control cycle-target"))
hl.bind(mainMod .. " + G",             hl.dsp.exec_cmd("steam"))
hl.bind(mainMod .. " + O",             hl.dsp.exec_cmd("obs"))
hl.bind(mainMod .. " + F",             hl.dsp.exec_cmd("foliate"))
hl.bind(mainMod .. " + SPACE",         hl.dsp.exec_cmd("handy --toggle-transcription"))
hl.bind("CTRL + SPACE",                hl.dsp.exec_cmd("handy --toggle-transcription"))
hl.bind(mainMod .. " + T",             hl.dsp.exec_cmd([[grim -g "$(slurp)" $HOME/screenshots/$(date +'%s_grim.png')]]))
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mainMod .. " + ALT + L",       hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + ALT + M",       hl.dsp.exit())

-- Move focus with mainMod + HJKL
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Resize active window (repeating = old binde)
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0 }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20 }),  { repeating = true })

-- Move window with mainMod + SHIFT + HJKL
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.center())

hl.bind("ALT + TAB",         hl.dsp.window.cycle_next({ next = true }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))

-- Switch / move between workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,                 hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,         hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key,          hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Scroll through existing workspaces with mainMod + - and =
hl.bind(mainMod .. " + minus", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + equal", hl.dsp.focus({ workspace = "e+1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())