{
  id = "noether";
  hostName = "noether";
  hardwareConfig = import ./noether-hardware.nix;
  enableSshServer = true;
  enableTailscale = true;
  enableHeadscale = true;
  enableDufs = true;
  enableNginx = true;
  tailscaleLoginServer = "https://headscale.jonbyr.com";
  homeManagerConfig = {};
}
