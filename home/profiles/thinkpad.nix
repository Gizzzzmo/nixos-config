{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../core.nix
    ../modules/hyprland.nix
    ../modules/gui-apps.nix
    ../modules/sound-apps.nix
    ../modules/syncthing.nix
  ];

  hm.waybarHeight = 28;

  home.packages = with pkgs; [
    inputs.matui.packages.${pkgs.system}.default
    mmtui
    bluetui
    darktable
  ];
}
