{
  pkgs,
  inputs,
  standalone,
  username,
  ...
} @ home_inputs: {
  targets.genericLinux.enable = standalone;

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

  imports = [inputs.nixvim.homeModules.nixvim];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      (
        writeShellScriptBin "update-cmus-playlists"
        (builtins.readFile ./scripts/update-cmus-playlists.sh)
      )
      (
        writeShellScriptBin "llama-ctl"
        (builtins.readFile ./scripts/llama-ctl.sh)
      )
      (
        writeShellScriptBin "multimux"
        (builtins.readFile ./scripts/multimux.sh)
      )
      (
        writeShellScriptBin "sourcemux"
        (builtins.readFile ./scripts/sourcemux.sh)
      )
      (
        writeShellScriptBin "envmux"
        (builtins.readFile ./scripts/envmux.sh)
      )
      (
        writeShellScriptBin "tmux-select-session-fzf"
        (builtins.readFile ./scripts/tmux-select-session-fzf.sh)
      )
      (
        writeShellScriptBin "sshmux"
        (builtins.readFile ./scripts/sshmux.sh)
      )
      (
        writeShellScriptBin "tmux"
        (builtins.replaceStrings
          ["REAL_TMUX=tmux"]
          ["REAL_TMUX=${pkgs.tmux}/bin/tmux"]
          (builtins.readFile ./scripts/tmux.sh))
      )
      jq
      ollama
      gh
      mmtui
      imagemagick
      file
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
      zathura
      (pkgs.nom.overrideAttrs (oldAttrs: {
        pname = "rss";
        # Optionally, you can rename the binary
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mv $out/bin/nom $out/bin/rss
          '';
      }))
      nix-output-monitor
    ]
    ++ lib.optionals ((home_inputs ? "useHyprland") && (home_inputs.useHyprland)) [
      (
        writeShellScriptBin "hyprpaper-ctl"
        (builtins.readFile ./scripts/hyprpaper-ctl.sh)
      )
    ]
    ++ lib.optionals (home_inputs ? "extraPkgs") (home_inputs.extraPkgs pkgs)
    ++ (
      if standalone
      then [
        gnupg
        cmake
        wslu
        neocmakelsp
        basedpyright
        just
      ]
      else
        with pkgs; [
          (
            writers.writePython3Bin
            "ghostty_wrap"
            {}
            (builtins.readFile ./scripts/ghostty_wrap.py)
          )
          veracrypt
          wiremix
          bluetui
          impala
          opencode
          keepassxc
          signal-desktop
          light
          cmus
          openvpn
          btop
          digikam
          # texpresso
          android-file-transfer
          webcamoid
          nemo
          vscode
          eog
          obsidian
          firefox
          vlc
          discord
          qbittorrent
          grim
          slurp
          foliate
        ]
    );

  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.gitui = (import ./programs/gitui.nix) home_inputs;
  programs.tmux = (import ./programs/tmux.nix) home_inputs;
  programs.git = (import ./programs/git.nix) home_inputs;
  programs.nixvim = (import ./programs/nixvim.nix) home_inputs;
  programs.fish = (import ./programs/fish.nix) home_inputs;
  programs.bat = (import ./programs/bat.nix) home_inputs;
  programs.qutebrowser = (import ./programs/qutebrowser.nix) home_inputs;
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" =
          if standalone
          then "wslview.desktop"
          else "qutebrowser.desktop";
        "application/pdf" = "zathura.desktop";
        "image/png" = "eog.desktop";
        "image/jpeg" = "eog.desktop";
      };
    };
  };
  programs.mpv = {
    enable = !standalone;
  };
  programs.ghostty =
    (import ./programs/ghostty.nix) home_inputs
    // {
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
      enable = (home_inputs ? "useHyprland") && home_inputs.useHyprland;
    };
  programs.hyprlock =
    (import ./programs/hyprlock.nix) home_inputs
    // {
      enable = (home_inputs ? "useHyprland") && home_inputs.useHyprland;
    };
  programs.obs-studio =
    (import ./programs/obs.nix) home_inputs
    // {
      enable = !standalone;
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

  services.hyprpolkitagent = {
    enable = (home_inputs ? "useHyprland") && home_inputs.useHyprland;
  };

  services.syncthing = {
    enable = !standalone;
  };

  services.gpg-agent = {
    enable = true;
    maxCacheTtl = 18000;
    defaultCacheTtl = 18000;
    pinentry.package = pkgs.pinentry-qt;
  };

  home.file = {
    ".config" = {
      source = dotfiles/.config;
      recursive = true;
    };
    ".XCompose" = {
      source = dotfiles/.XCompose;
    };
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
      else "qutebrowser";
    MANPAGER = "nvim +Man!";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
