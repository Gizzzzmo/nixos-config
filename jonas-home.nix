{
  nixpkgs,
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

  imports = [inputs.nixvim.homeModules.nixvim];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
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

      inputs.muxxies.defaultPackage.${pkgs.system}
      alejandra
      ruff
      shfmt
      xdg-utils
      lsof
      usbutils
      proximity-sort
      nodejs
      ncdu
      netcat-openbsd
      nh
      nvd
      wl-clipboard
      wl-clipboard-x11
      python313
      python313Packages.ipython
      python313Packages.ptpython
      fishPlugins.bass
      ast-grep
      wiki-tui
      glab
      gurk-rs
      (pkgs.nom.overrideAttrs (oldAttrs: {
        pname = "nix-output-monitor-cli";
        # Optionally, you can rename the binary
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mv $out/bin/nom $out/bin/rss
          '';
      }))
      nix-output-monitor
    ]
    ++ (
      if standalone
      then [
        cmake
        wslu
        neocmakelsp
        basedpyright
        just
      ]
      else
        with pkgs; [
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
  programs.qutebrowser = (import ./programs/qutebrowser.nix) home_inputs;

  services.gpg-agent =
    {
      enable = true;
      maxCacheTtl = 18000;
    }
    // (
      if standalone
      then {}
      else {pinentry.package = pkgs.pinentry-rofi;}
    );

  programs.ghostty = {
    enable = !standalone;
    enableFishIntegration = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 12;
    };
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
  programs.hyprlock =
    (import ./programs/hyprlock.nix) home_inputs
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
      else "qutebrowser";
    MANPAGER = "nvim +Man!";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
