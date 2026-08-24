{
  lib,
  pkgs,
  ...
}: let
  sshBin = "${pkgs.openssh}/bin/ssh";
in {
  systemd.services.hermes-tunnel = {
    description = "SSH tunnel to run hermes on the remote and expose its port on the Tailscale interface";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      User = "jonas";
      ExecStart = ''
        ${sshBin} -oServerAliveInterval=30 -oServerAliveCountMax=2 \
          -L 127.0.0.1:9119:127.0.0.1:9120 \
          guy@46.225.139.112 "HERMES_DASHBOARD_SESSION_TOKEN=$(cat /home/guy/.hermes/dashboard_session_token) hermes serve --port 9120"
      '';
      Restart = "on-failure";
      RestartSec = "5s";
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "hermes";
    };
  };
}
