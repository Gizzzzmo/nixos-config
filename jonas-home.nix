{nixpkgs, config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jonas";
  home.homeDirectory = "/home/jonas";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.eog
    pkgs.vscode
    pkgs.obs-studio
    pkgs.obsidian
    pkgs.git
    pkgs.waybar
    pkgs.gitui
    pkgs.firefox
    pkgs.wofi
    pkgs.tree
    pkgs.vlc
    pkgs.discord
    pkgs.zoxide
    pkgs.fzf
    pkgs.ripgrep
    pkgs.starship
    pkgs.nushell
    pkgs.kpcli
    pkgs.home-manager
    pkgs.qbittorrent
    pkgs.openocd
    pkgs.gdb
    pkgs.clang
    pkgs.grim
    pkgs.slurp
    pkgs.tmux
    pkgs.foliate
    pkgs.zathura
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = ["FiraCode" "CascadiaCode"]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  programs.wofi = {
    enable = true;
    style = ''
    /* ::root{ */
/*     --accent: #5291e2; */
/*     --dark:   #383C4A; */
/*     --light:  #7C818C; */
/*     --ld:     #404552; */
/*     --dl:     #4B5162 */
/*     --white:  white; */
/* } */

*{
  font-family: FiraCode Nerd Font;
  font-size: 1.04em;
}

window{
  background-color: #7C818C;
}

#input {
  margin: 5px;
  border-radius: 3px;
  border: none;
  border-bottom: 3px solid grey;
  background-color: #383C4A;
  color: white;
  font-size: 2em;
}

/* search icon */
#input:first-child > :nth-child(1) {
  min-height: 1.25em;
  min-width: 1.25em;
  background-image: -gtk-icontheme('open-menu-symbolic');
}

/* clear icon */
#input:first-child > :nth-child(4){
  min-height: 1.25em;
  min-width: 1.25em;
  background-image: -gtk-icontheme('window-close-symbolic');
}

#inner-box {
  background-color: #383C4A;
}

#outer-box {

  margin: 2px;
  padding:0px;
  background-color: #383C4A;
}

#text {
  padding: 5px;
  color: white;
}

#entry:selected {
  background-color: #5291e2;
}

#text:selected {
}

#scroll {
}

#img {
}

/* Give color to even items */
/* #entry:nth-child(even){ */
/*     background-color: #404552; */
/* } */
    '';
  };
  programs.git = {
    enable = true;
    userName = "Jonas Beyer";
    userEmail = "reyeb.sanoj@googlemail.com";
    
    extraConfig = {
        init.defaultBranch = "main";
    };
    lfs.enable = true;
  };
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      eamodio.gitlens
      #vscodevim.vim
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      enkia.tokyo-night
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # binascii.hexlify(base64.b64decode('8QQmTUIxQZo3owpCNh+5IjtnoNNvd0M1FI3cJrFG5Rg=')).decode("utf-8")
      #
      # codeium tries to download its own language server binary which is incompatible with nix's non-fsh compliant filesystem, and it seems to be impossible to point the extension to another location for the language server binary
      #{
      #  name = "codeium";
      #  publisher = "Codeium";
      #  version = "1.17.4";
      #  sha256 = "bafae9048f2d7143fae122f5dd4400c2da3ee06614d131b4fb7bb79aa4c8869e";
      #}
      {
        name = "cmake-language-support-vscode";
        publisher = "josetr";
        version = "0.0.9";
        sha256 = "2cdb57619eb92e46b5969c5e2a8ccae8b074c9ac408c7b1f56c089f082d7f22a";
      }
    ];
    userSettings = {
      "[nix]"."editor.tabSize" = 2;
      "editor.stickyScroll.enabled" = false;
      "editor.fontFamily" = "FiraCode Nerd Font";
      "editor.fontSize" = 14;
      "extensions.ignoreRecommendations" = true;
      "cmake.showOptionsMovedNotification" = false;
      "cmake.showNotAllDocumentsSavedQuestion" = false;
      "cmake.pinnedCommands"= [
        "workbench.action.tasks.configureTaskRunner"
        "workbench.action.tasks.runTask"
      ];
      "update.mode"= "none";
      "workbench.colorTheme" = "Tokyo Night Pure";
      "window.menuBarVisibility" = "toggle";
    }; # keybindings are in dotfiles/.config/Code/User/keybindings.json
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };

  programs.command-not-found.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/home/jonas/.config/alacritty/tokyo-night.toml" ];
      window = {
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.8;
      };
      font = {
        normal = {
          family = "CaskaydiaCove Nerd Font";
          style = "Regular";
        };
        size = 12.5;
      };
    };

  };

  programs.nixvim = {
    enable = true;
    extraPlugins = with pkgs.vimPlugins; [
      codeium-nvim
    ];
    opts = {
        number = true;
	relativenumber = true;
	shiftwidth = 4;
	expandtab = true;
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      "..." = "cd ../..";
      ".." = "cd ..";
    };
    shellInit = "set fish_greeting";
  };

  programs.nushell = {
    enable = true;
  };

  programs.starship = {
    enable = true; 
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = ["--cmd cd"];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [{
      layer = "top";
      position = "top"; # Waybar at the bottom of your screen
      height = 24; # Waybar height
      # width= 1366; // Waybar width
      # Choose the order of the modules
      modules-left = ["sway/workspaces" "sway/mode" "custom/spotify"];
      modules-center= ["sway/window"];
      modules-right= ["pulseaudio" "network" "cpu" "memory" "battery" "tray" "clock"];
      "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          format = "{icon}";
          format-icons = {
              "1:web"= "";
              "2:code" = "";
              "3:term" = "";
              "4:work" = "";
              "5:music" = "";
              "6:docs" = "";
              urgent= "";
              focused= "";
              default= "";
          };
      };
      "sway/mode" = {
          format = "<span style=\italic\>{}</span>";
      };
      tray = {
          # icon-size= 21;
          spacing = 10;
      };
      clock = {
          format-alt = "{=%Y-%m-%d}";
      };
      cpu = {
          format = "{usage}% ";
      };
      memory = {
          format= "{}% ";
      };
      battery = {
          bat = "BAT0";
          states = {
              # good = 95;
              warning = 30;
              critical = 15;
          };
          format = "{capacity}% {icon}";
          # format-good = ; // An empty format will hide the module
          # format-full = ;
          format-icons = ["" "" "" "" ""];
      };
      network = {
          # interface = wlp2s0; // (Optional) To force the use of this interface
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname}= {ipaddr}/{cidr} ;";
          format-disconnected = "Disconnected ⚠";
      };
      pulseaudio= {
          #scroll-step = 1;
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" ""];
          };
          on-click = "pavucontrol";
      };
      "custom/spotify" = {
          format = " {}";
          max-length = 40;
          interval = 30; # Remove this if your script is endless and write in loop
          exec = pkgs.writeShellScript "mediaplayer" ''
          player_status=$(playerctl status 2> /dev/null)
          if [ "$player_status" = "Playing" ]; then
              echo "$(playerctl metadata artist) - $(playerctl metadata title)"
          elif [ "$player_status" = "Paused" ]; then
              echo " $(playerctl metadata artist) - $(playerctl metadata title)"
          fi
          '';
          #"$HOME/.config/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
          exec-if = "pgrep spotify";
      };
    }];
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
    color: white;
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
    color: white;
    border-top: 2px solid transparent;
}

#workspaces button.focused {
    color: #c9545d;
    border-top: 2px solid #c9545d;
}

#mode {
    background: #64727D;
    border-bottom: 3px solid white;
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
    animation-duration: 0.5s;
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
  };
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config" = {
      source = dotfiles/.config;
      recursive = true;
    };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jonas/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
