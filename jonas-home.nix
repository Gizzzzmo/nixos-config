{
  #000000#000000  nixpkgs,
  config,
  pkgs,
  inputs,
  standalone,
  username,
  ...
} @ home_inputs: {
  targets.genericLinux.enable = standalone;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  imports = [inputs.nixvim.homeManagerModules.nixvim];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      inputs.muxxies.defaultPackage.${pkgs.system}
      alejandra
      ruff
      shfmt
      xdg-utils
      lsof
      fd
      proximity-sort
      nodejs
      ncdu
      nh
      keepassxc
      nix-output-monitor
      nvd
      openvpn
      cmus
      wl-clipboard
      wl-clipboard-x11
      python313
      python313Packages.ipython
      python313Packages.ptpython
      fishPlugins.bass
      fishPlugins.colored-man-pages
      eza
      tree
      ripgrep
      ast-grep
      htop
      unzip
      zip
      glab
    ]
    ++ (
      if standalone
      then [
        wslu
        neocmakelsp
      ]
      else
        with pkgs; [
          # texpresso
          nemo
          kitty
          alacritty
          pavucontrol
          vscode
          eog
          obs-studio
          obsidian
          waybar
          firefox
          vlc
          wofi
          discord
          qbittorrent
          grim
          slurp
          foliate
          zathura
          # # Adds the 'hello' command to your environment. It prints a friendly
          # # "Hello, world!" when run.
          # pkgs.hello

          # # It is sometimes useful to fine-tune packages, for example, by applying
          # # overrides. You can do that directly here, just don't forget the
          # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
          # # fonts?
          # # You can also create simple shell scripts directly inside your
          # # configuration. For example, this adds a command 'my-hello' to your
          # # environment:
          # (pkgs.writeShellScriptBin "my-hello" ''
          #   echo "Hello, ${config.home.username}!"
          # '')
        ]
    );

  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.gitui = (import ./programs/gitui.nix) home_inputs;
  programs.tmux = (import ./programs/tmux.nix) home_inputs;
  programs.git = (import ./programs/git.nix) home_inputs;
  programs.nixvim = (import ./programs/nixvim.nix) home_inputs;
  programs.fish = (import ./programs/fish.nix) home_inputs;
  programs.bat = (import ./programs/bat.nix) home_inputs;

  programs.kitty =
    (import ./programs/kitty.nix) home_inputs
    // {
      enable = !standalone;
    };
  programs.mpv = {
    enable = !standalone;
  };
  programs.wofi =
    (import ./programs/wofi.nix) home_inputs
    // {
      enable = !standalone;
    };
  programs.vscode =
    (import ./programs/vscode.nix) home_inputs
    // {
      enable = !standalone;
    };
  programs.alacritty =
    (import ./programs/alacritty.nix) home_inputs
    // {
      enable = !standalone;
    };
  programs.waybar =
    (import ./programs/waybar.nix) home_inputs
    // {
      enable = !standalone;
    };

  programs.command-not-found.enable = true;
  programs.nushell.enable = true;
  programs.yt-dlp.enable = true;

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

  programs.hyprlock = {
    enable = !standalone;

    settings = {
      general = {
        disable_loading_bar = false;
        grace = 0;
        hide_cursor = false;
        no_fade_in = true;
      };

      auth = {
        enabled = true;
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
    ".XCompose" = {
      source = dotfiles/.XCompose;
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
    BROWSER =
      if standalone
      then "wslview"
      else "firefox";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
