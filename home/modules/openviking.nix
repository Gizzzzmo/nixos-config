{pkgs, ...}: {
  systemd.user.services.openviking = {
    Unit.Description = "OpenViking server for AI agents";
    Install.WantedBy = ["default.target"];
    Service = {
      ExecStart = "/home/jonas/.local/bin/openviking-server";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
