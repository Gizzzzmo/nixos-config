{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
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
in {
  home.packages = with pkgs; [
    element-desktop
    foliate
    eog
    obsidian
    firefox
    vlc
    discord
    qbittorrent
    via
    qmk
    signal-desktop
    webcamoid
    digikam
    zathura
    nemo
  ];

  programs.qutebrowser =
    (import ../programs/qutebrowser.nix) homeArgs
    // {
      enable = true;
    };
  programs.mpv.enable = true;
  programs.ghostty =
    (import ../programs/ghostty.nix) homeArgs
    // {
      enable = true;
    };
  programs.wofi =
    (import ../programs/wofi.nix) homeArgs
    // {
      enable = true;
    };
  programs.vscode =
    (import ../programs/vscode.nix) homeArgs
    // {
      enable = true;
    };
  programs.alacritty =
    (import ../programs/alacritty.nix) homeArgs
    // {
      enable = true;
    };
  programs.obs-studio =
    (import ../programs/obs.nix) homeArgs
    // {
      enable = true;
    };
}
