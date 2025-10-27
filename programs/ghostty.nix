{...}: {
  enable = true;
  enableFishIntegration = true;
  settings = {
    font-family = "FiraCode Nerd Font";
    font-size = 12.5;
    background-opacity = "0.8";
    background = "#131313";
    mouse-scroll-multiplier = "precision:0.5,discrete:2";
    confirm-close-surface = false;
    keybind = [
      "ctrl+9=set_font_size:8.9"
      "ctrl+shift+enter=toggle_fullscreen"
      "ctrl+enter=unbind"
    ];
  };
}
