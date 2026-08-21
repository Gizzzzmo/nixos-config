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
    ../modules/handy.nix
  ];

  hm = {
    waybarHeight = 36;
    waybarOpacity = 0.6;
  };

  home.packages = with pkgs; [
    mmtui
    bluetui
    (darktable.override {withAi = true;})
    ollama
    lmstudio
    ardour
    kdePackages.kdenlive
  ];
}
