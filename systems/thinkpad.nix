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
}
