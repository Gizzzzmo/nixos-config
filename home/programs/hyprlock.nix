{...}: {
  settings = {
    general = {
      grace = 0;
      hide_cursor = false;
    };

    animations = {
      enabled = false;
    };

    background = [
      {
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }
    ];

    input-field = [
      {
        size = "300, 50";
        position = "0, -80";
        monitor = "";
        dots_center = false;
        fade_on_empty = false;
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgb(91, 96, 120)";
        outer_color = "rgba(5555eeff) rgba(222288ff) 45deg";
        check_color = "rgba(5555eeff) rgba(222288ff) 45deg";
        fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";
        outline_thickness = 3;
        placeholder_text = "Password...";
        shadow_passes = 0;
        fail_text = "$PAMFAIL";
      }
    ];

    label = [
      {
        monitor = "";
        text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
        font_size = 90;
        # font_family = $font

        position = "-30, 0";
        halign = "right";
        valign = "top";
      }
      {
        monitor = "";
        text = ''cmd[update:60000] date +"%A, %d %B %Y"''; # update every 60 seconds
        font_size = 25;
        # font_family = $font;

        position = "-30, -150";
        halign = "right";
        valign = "top";
      }
      # TODO: will be implemented in next hyprlock release
      {
        monitor = "";
        text = "$LAYOUT[en,de]";
        font_size = 18;
        onclick = "hyprctl switchxkblayout all next";

        position = "250, -20";
        halign = "center";
        valign = "center";
      }
    ];
  };
}
