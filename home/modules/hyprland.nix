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
  hm.useHyprland = true;

  home.packages = with pkgs; [
    (
      writeShellScriptBin "hyprpaper-ctl"
      (builtins.readFile ../../scripts/hyprpaper-ctl.sh)
    )
    (
      writeShellScriptBin "cmus-control"
      (builtins.readFile ../../scripts/cmus-control.sh)
    )
    (
      writers.writePython3Bin
      "ghostty_wrap"
      {}
      (builtins.readFile ../../scripts/ghostty_wrap.py)
    )
    acpilight
    grim
    slurp
  ];

  programs.waybar = (import ../programs/waybar.nix) homeArgs;
  programs.hyprlock = (import ../programs/hyprlock.nix) homeArgs;
  services.hyprpolkitagent.enable = true;
}
