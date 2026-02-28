{
  id = "thinkpad";
  hardwareConfig = import ./thinkpad-hardware.nix;
  enableBluetooth = true;
  # enableIwd = true;
  enableUserMounts = true;
  enablePrinting = true;
  enableSteam = true;
  enableSound = true;
  enableGui = true;
  enableTailscale = true;
  extraUdevRules = pkgs: ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chgrp backlight $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/coreutils --coreutils-prog=chmod g+w $sys$devpath/brightness"
  '';
  homeManagerConfig = {
    waybarHeight = 28;
    extraPkgs = pkgs:
      with pkgs; [
        darktable
      ];
  };
}
