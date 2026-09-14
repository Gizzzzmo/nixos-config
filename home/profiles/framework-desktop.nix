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
    handy
    # nixpkgs ardour links jack2; wrap it so libjack.so.0 resolves to
    # pipewire's implementation (UWSM drops the session LD_LIBRARY_PATH
    # that NixOS's pipewire jack module normally relies on).
    (symlinkJoin {
      name = "ardour-pipewire";
      paths = [ardour];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/ardour9" \
          --prefix LD_LIBRARY_PATH : "${pipewire.jack}/lib"
      '';
    })
    kdePackages.kdenlive
  ];
}
