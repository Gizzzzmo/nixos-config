-- Hyprland config entry point (part of the NixOS repo, managed via
-- Home-Manager): not edited by hand. Practical config lives in ./config/.
-- Per-machine monitors are generated into config/monitors.lua by Nix.

require("config.env")
require("config.monitors")
require("config.input")
require("config.general")
require("config.keybinds")
require("config.autostart")