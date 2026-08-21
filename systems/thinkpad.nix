{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/core.nix
    ../modules/main-user.nix
    ../modules/services/ssh.nix
    ../modules/services/gui.nix
    ../modules/services/audio.nix
    ../modules/services/bluetooth.nix
    ../modules/services/tailscale.nix
    ../modules/services/steam.nix
    ../modules/services/printing.nix
    ../modules/services/storage-box.nix
    ../modules/services/user-mounts.nix
    ../modules/services/home-manager.nix
    ./thinkpad-hardware.nix
  ];

  main-user.enable = true;
  main-user.userName = "jonas";

  sys = {
    hostName = "nixos";
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chgrp backlight $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chmod g+w $sys$devpath/brightness"
  '';

  hm.profile = ../home/profiles/thinkpad.nix;
}
