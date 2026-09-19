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

  sys.controlPanel.actions.restartTailscaled = {
    title = "Restart tailscaled";
    shell = "systemctl restart tailscaled";
    unit = "tailscaled.service";
    icon = "restart";
    timeout = 60;
    # Restarting tailscaled tears down tailscale0 for a few seconds — tailnet
    # connectivity (including this panel) drops until it comes back up.
    confirmation = true;
  };
}
