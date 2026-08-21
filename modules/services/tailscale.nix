{
  lib,
  config,
  ...
}: {
  services.tailscale = {
    enable = true;
    authKeyFile = "/root/tailscale-auth-key";
    extraUpFlags = [
      "--login-server=${config.sys.tailscaleLoginServer}"
      "--accept-routes"
      "--advertise-exit-node"
    ];
    useRoutingFeatures = "client";
  };

  systemd.services.tailscaled-autoconnect.serviceConfig = {
    TimeoutStartSec = "5min";
  };

  networking.firewall.trustedInterfaces = ["tailscale0"];
}