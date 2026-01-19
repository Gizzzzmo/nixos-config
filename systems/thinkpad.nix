{
  id = "thinkpad";
  hardwareConfig = ./thinkpad-hardware.nix;
  enableBluetooth = true;
  # enableIwd = true;
  enableUserMounts = true;
  enablePrinting = true;
  enableSteam = true;
  enableSound = true;
  enableGui = true;
}
