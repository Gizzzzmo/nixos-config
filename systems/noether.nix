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
  tailscaleIp = "100.64.0.5";
  enableLegacyBios = true;
  enableStorageBox = true;
  enableAutoUpgrade = true;
  enableGitServer = true;
  enableMatrixServer = true;
  homeManagerConfig = {
    enableSyncthing = true;
    enableGui = false;
  };
}
