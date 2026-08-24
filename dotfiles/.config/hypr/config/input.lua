-- Input / keyboard / touchpad.
local hl = hl

hl.config({
    input = {
        kb_layout  = "us,de,us",
        kb_variant = "altgr-intl,,intl",
        kb_model   = "",
        kb_rules   = "",
        kb_options = "compose:caps",

        follow_mouse = 2,

        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.6,
        },

        sensitivity = 0,
    },
})
