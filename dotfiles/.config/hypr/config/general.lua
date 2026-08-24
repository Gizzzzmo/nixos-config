-- Look and feel: window decorations, layout, appearance.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
local hl = hl

-- Cursor
hl.config({ cursor = { inactive_timeout = 5 } })

-- General window behavior
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 3,

        border_size = 6,

        col = {
            active_border   = "rgba(ffffff88)",
            inactive_border = "rgba(00000000)",
        },

        layout = "dwindle",

        allow_tearing = false,
    },
})

-- Decoration
hl.config({
    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },
})

-- Animations
hl.config({ animations = { enabled = false } })

-- Dwindle layout
hl.config({ dwindle = { preserve_split = true } })

-- XWayland
hl.config({ xwayland = { force_zero_scaling = true } })

-- Misc
hl.config({ misc = { force_default_wallpaper = 0 } })

-- Per-device
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
