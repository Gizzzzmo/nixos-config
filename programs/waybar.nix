{...} @ home_inputs: let
  waybarHeight =
    if (home_inputs ? "waybarHeight")
    then home_inputs.waybarHeight
    else 30;
in {
  enable = true;
  systemd.enable = true;
  settings = [
    {
      layer = "top";
      position = "top"; # Waybar at the bottom of your screen
      height = waybarHeight; # Waybar height
      # width= 1366; // Waybar width
      # Choose the order of the modules

      modules-left = ["clock" "battery" "bluetooth" "network"];
      modules-center = ["hyprland/workspaces"];
      modules-right = [
        "tray"
        "pulseaudio"
        "hyprland/language"
        "cpu"
        "memory"
        "disk"
      ];

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
        on-click = "ghostty_wrap -e bluetui";
      };

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = false;
        format = "{icon}";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          "10" = "0";
          default = "...";
        };
      };
      tray = {
        icon-size = 16;
        spacing = 10;
      };
      clock = {
        format = " {:%H:%M}   |";
        format-alt = " {:%R, %B %d} |";
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
        format = "| {usage}%  ";
        on-click = "ghostty_wrap --font-size=8.9 -e btop";
      };
      memory = {
        format = "| {}%  ";
      };
      disk = {
        format = "| {percentage_used}%   ";
        path = "/";
        on-click = "ghostty_wrap -e mmtui";
        on-click-right = "ghostty_wrap -e ncdu --exclude 'mnt/**' ~";
      };
      battery = {
        bat = "BAT0";
        states = {
          # good = 95;
          warning = 30;
          critical = 7;
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
        format-wifi = "  {signalStrength}%";
        format-ethernet = "{ifname}  ";
        format-disconnected = " - ⚠";
        tooltip-format-wifi = "{essid}";
        on-click = "ghostty_wrap -e impala";
      };
      pulseaudio = {
        scroll-step = 2;
        format = "{volume}% {icon}  |";
        format-bluetooth = "{volume}% {icon}   |";
        format-muted = "      |";
        format-icons = {
          headphones = "";
          # handsfree = "";
          # headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
          ];
        };
        on-click = "ghostty_wrap -e wiremix";
      };
    }
  ];
  style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "CaskaydiaCove Nerd Font";
      font-size: ${toString (waybarHeight / 2)}px;
      min-height: 0;
    }

    window#waybar {
      background-color: rgba(0, 0, 0, 0.5);
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
      padding: 0 0.8rem;
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

    #clock:hover, #bluetooth:hover, #network:hover {
      color: #ffffff;
    }

    #battery, #network, #clock, #bluetooth {
      color: #dddddd;
    }

    #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode {
      padding: 0 3px;
      margin: 0 2px;
    }

    #clock {
      font-weight: bold;
    }

    #battery icon {
      color: red;
    }

    @keyframes blink {
      to {
          background-color: #ffffff;
          color: black;
      }
    }

    #battery.critical:not(.charging) {
      color: #f53c3c;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #battery.warning:not(.charging) {
      color: white;
      animation-name: blink;
      animation-duration: 0.75s;
      animation-timing-function: linear;
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #network.disconnected {
      background: #f53c3c;
    }
  '';
}
