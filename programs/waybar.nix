{pkgs, ...}: {
  enable = true;
  systemd.enable = true;
  settings = [
    {
      layer = "top";
      position = "top"; # Waybar at the bottom of your screen
      height = 24; # Waybar height
      # width= 1366; // Waybar width
      # Choose the order of the modules

      modules-left = ["clock" "battery" "bluetooth" "network"];
      modules-center = ["hyprland/workspaces"];
      modules-right = [
        "tray"
        "custom/cmus"
        "pulseaudio"
        "hyprland/language"
        "cpu"
        "memory"
      ];
      "custom/cmus" = {
        format = "| ♪ {text} |";
        # "max-length"= 15;
        interval = 10;
        exec = ''cmus-remote -C "format_print '%t'" | sed 's/\(.\{15\}\).*/\1.../' ''; # artist - title
        exec-if = "pgrep cmus";
        on-click = "cmus-remote -u"; # toggle pause
        on-click-right = "ghostty -e tmux at -t cmux";
        escape = true; # handle markup entities
      };
      "hyprland/language" = {
        format = " {} ⌨ ";
        format-de = "DE";
        format-us = "US";
        format-en = "US";
        on-click = "hyprctl switchxkblayout all next";
      };

      "bluetooth" = {
        format = " - |";
        format-connected = " {device_alias} |";
        tooltip-format = "{device_enumerate}";
        tooltip = true;
        on-click = "ghostty -e bluetui";
      };

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = false;
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          default = "...";
        };
      };
      tray = {
        icon-size = 16;
        spacing = 10;
      };
      clock = {
        format = "{:%H:%M}   |";
        format-alt = "{:%A, %B %d, %Y (%R)}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-click-forward = "tz_up";
          on-click-backward = "tz_down";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };
      cpu = {
        format = "| {usage}% ";
        on-click = "ghostty -e btop";
      };
      memory = {
        format = "| {}%  ";
      };
      battery = {
        bat = "BAT0";
        states = {
          # good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}  |";
        # format-good = ; // An empty format will hide the module
        # format-full = ;
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
        on-scroll-up = "light -A 2";
        on-scroll-down = "light -U 2";
      };

      network = {
        # interface = wlp2s0; // (Optional) To force the use of this interface
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname} ;";
        format-disconnected = "Disconnected ⚠";
      };
      pulseaudio = {
        scroll-step = 2;
        format = "{volume}% {icon}  |";
        format-bluetooth = "{volume}% {icon}   |";
        format-muted = "      |";
        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
          ];
        };
        on-click = "pavucontrol";
      };
      # "custom/spotify" = {
      #   format = " {}";
      #   max-length = 40;
      #   interval = 30; # Remove this if your script is endless and write in loop
      #   exec = pkgs.writeShellScript "mediaplayer" ''
      #     player_status=$(playerctl status 2> /dev/null)
      #     if [ "$player_status" = "Playing" ]; then
      #         echo "$(playerctl metadata artist) - $(playerctl metadata title)"
      #     elif [ "$player_status" = "Paused" ]; then
      #         echo " $(playerctl metadata artist) - $(playerctl metadata title)"
      #     fi
      #   '';
      #   #"$HOME/.config/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
      #   exec-if = "pgrep spotify";
      # };
    }
  ];
  style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "CaskaydiaCove Nerd Font";
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: transparent;
      color: #eeeeee;
    }

    #window {
      font-weight: bold;
      font-family: "CaskaydiaCove Nerd Font";
    }
    /*
    #workspaces {
      padding: 0 5px;
    }
    */

    #workspaces button {
      padding: 0 5px;
      background: transparent;
      color: #aaaaaa;
      border-top: 2px solid transparent;
    }

    #workspaces button.active {
      color: white;
      border-top: 2px solid #d77786;
    }

    #mode {
      background: #64727D;
      border-bottom: 3px solid white;
    }

    #battery, #network, #clock, #bluetooth {
      color: #cccccc;
    }

    #clock, #battery, #cpu, #memory, #network, #pulseaudio, #custom-spotify, #tray, #mode {
      padding: 0 3px;
      margin: 0 2px;
    }

    #clock {
      font-weight: bold;
    }

    #battery {
    }

    #battery icon {
      color: red;
    }

    #battery.charging {
    }

    @keyframes blink {
      to {
          background-color: #ffffff;
          color: black;
      }
    }

    #battery.warning:not(.charging) {
      color: white;
      animation-name: blink;
      animation-duration: 0.75s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #cpu {
    }

    #memory {
    }

    #network {
    }

    #network.disconnected {
      background: #f53c3c;
    }

    #pulseaudio {
    }

    #pulseaudio.muted {
    }

    #custom-spotify {
      color: rgb(102, 220, 105);
    }

    #tray {
    }
  '';
}
