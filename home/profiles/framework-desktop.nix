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
    inputs.matui.packages.${pkgs.system}.default
    inputs.hermes.packages.${pkgs.system}.desktop
    mmtui
    bluetui
    (darktable.override {withAi = true;})
    ollama
    lmstudio
    ardour
    kdePackages.kdenlive
  ];
}
