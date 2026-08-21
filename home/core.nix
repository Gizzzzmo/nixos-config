{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  # Rebuild the args object consumed by programs/*.nix and neovim plugin
  # files, sourced from the hm.* options instead of passed specialArgs.
  homeArgs =
    {
      inherit pkgs inputs lib;
      username = "jonas";
      extraPkgs = pkgs: [];
      wsl = config.hm.wsl;
    }
    // {
      inherit (config.hm) standalone useHyprland waybarHeight waybarOpacity;
    };
  zen = pkgs.writeShellApplication {
    name = "zen";
    runtimeInputs = [pkgs.coreutils];
    text = builtins.readFile ../scripts/zen.sh;
  };
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  options.hm = {
    standalone = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Standalone (non-NixOS) home-manager, e.g. WSL.";
    };
    wsl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "WSL-specific behavior (mime apps, browser, xdg).";
    };
    useHyprland = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use Hyprland (defined by the hyprland module).";
    };
    waybarHeight = lib.mkOption {
      type = lib.types.int;
      default = 30;
    };
    waybarOpacity = lib.mkOption {
      type = lib.types.number;
      default = 0.5;
    };
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          output = lib.mkOption {
            type = lib.types.str;
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "preferred";
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "auto";
          };
          scale = lib.mkOption {
            type = lib.types.str;
            default = "auto";
          };
          bitdepth = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
          };
        };
      });
      default = [
        {
          output = "eDP-1";
          mode = "1920x1080";
          position = "0x216";
          scale = "1.5";
          bitdepth = 10;
        }
        {
          output = "DP-1";
          mode = "2560x1440";
          position = "1280x0";
          scale = "1";
          bitdepth = 10;
        }
        {
          output = "DP-5";
          mode = "1680x1050";
          position = "3840x51";
          scale = "1";
          bitdepth = 10;
        }
      ];
      description = "Monitor rules rendered into the Hyprland Lua config.";
    };
  };

  config = {
    targets.genericLinux.enable = config.hm.standalone;

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

    home.packages = with pkgs; [
      (
        writeShellScriptBin "update-cmus-playlists"
        (builtins.readFile ../scripts/update-cmus-playlists.sh)
      )
      zen
      (
        writeShellScriptBin "llama-ctl"
        (builtins.readFile ../scripts/llama-ctl.sh)
      )
      (
        writeShellScriptBin "multimux"
        (builtins.readFile ../scripts/multimux.sh)
      )
      (
        writeShellScriptBin "sourcemux"
        (builtins.readFile ../scripts/sourcemux.sh)
      )
      (
        writeShellScriptBin "envmux"
        (builtins.readFile ../scripts/envmux.sh)
      )
      (
        writeShellScriptBin "tmux-select-session-fzf"
        (builtins.readFile ../scripts/tmux-select-session-fzf.sh)
      )
      bash
      waypipe
      glow
      socat
      jq
      ollama
      gh
      (pkgs.nom.overrideAttrs (oldAttrs: {
        pname = "rss";
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mv $out/bin/nom $out/bin/rss
          '';
      }))
      imagemagick
      file
      xxd
      eza
      tree
      ripgrep
      ripgrep-all
      hyperfine
      xh
      fd
      htop
      unzip
      zip
      wget
      veracrypt
      btop
      keepassxc
      gnupg

      openvpn
      opencode
      alejandra
      ruff
      shfmt
      lsof
      usbutils
      proximity-sort
      ncdu
      netcat-openbsd
      nvd
      wl-clipboard
      wl-clipboard-x11
      python313
      python313Packages.ipython
      fishPlugins.bass
      glab
      nix-output-monitor
    ];

    nixpkgs.config.allowUnfreePredicate = pkg: true;

    programs.gitui = (import programs/gitui.nix) homeArgs;
    programs.tmux = (import programs/tmux.nix) homeArgs;
    programs.git = (import programs/git.nix) homeArgs;
    programs.nixvim = (import programs/nixvim.nix) homeArgs;
    programs.fish = (import programs/fish.nix) homeArgs;
    programs.bat = (import programs/bat.nix) homeArgs;
    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" =
            if config.hm.wsl
            then "wslview.desktop"
            else "qutebrowser.desktop";
          "application/pdf" = "zathura.desktop";
          "image/png" = "eog.desktop";
          "image/jpeg" = "eog.desktop";
        };
      };
    };
    programs.command-not-found.enable = true;
    programs.nushell.enable = true;
    programs.yt-dlp.enable = true;

    programs.direnv = {
      enable = true;
      # enableFishIntegration = true;
      # enableBashIntegration = true;
      nix-direnv.enable = true;
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

    services.gpg-agent = {
      enable = true;
      maxCacheTtl = 18000;
      defaultCacheTtl = 18000;
      pinentry.package = pkgs.pinentry-qt;
    };

    home.file = {
      ".config" = {
        source = ../dotfiles/.config;
        recursive = true;
      };
      ".XCompose" = {
        source = ../dotfiles/.XCompose;
      };
    };

    home.sessionVariables =
      {
        EDITOR = "nvim";
        BROWSER =
          if config.hm.wsl
          then "wslview"
          else "qutebrowser";
        MANPAGER = "nvim +Man!";
        _ZO_EXCLUDE_DIRS = "/home/jonas/mnt/storagebox/**";
      }
      // lib.optionalAttrs (!config.hm.standalone) {
        PATH = "/home/jonas/.local/state/zen/bin:/home/jonas/.local/state/zen/system-bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin";
      };

    systemd.user.sessionVariables = lib.mkIf (!config.hm.standalone) {
      PATH = "/home/jonas/.local/state/zen/bin:/home/jonas/.local/state/zen/system-bin:/run/wrappers/bin:/nix/var/nix/profiles/default/bin";
    };

    home.activation.zen = lib.mkIf (!config.hm.standalone) (lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${zen}/bin/zen --refresh
    '');

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
