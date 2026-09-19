{
  lib,
  config,
  ...
}: {
  services.nginx.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "jonas@jonbyr.com";
  };

  # Catch-all: the default server for the tailnet HTTP port. Anything that
  # does not hit a known server_name (unknown hosts, missing Host) is dropped
  # here. The bare <hostname>.headscale.local name is served by the control
  # panel vhost (modules/services/control-panel.nix) when the panel is
  # enabled; with the panel off it falls through to this catch-all and is
  # dropped too.
  services.nginx.virtualHosts."tailnet-reserved" = {
    listen = [
      {
        addr = config.sys.bindAddress;
        port = 80;
        ssl = false;
      }
    ];
    default = true;
    locations."/" = {
      return = "444";
    };
    # no access log: unknown hosts are just dropped
    extraConfig = ''
      error_log /var/log/nginx/hermes_reserved_error.log;
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];

  sys.controlPanel.actions.restartNginx = {
    title = "Restart nginx";
    shell = "systemctl restart nginx";
    unit = "nginx.service";
    icon = "restart";
    timeout = 30;
    # nginx fronts headscale and the hermes vhost — a mid-flight restart
    # briefly drops tailnet HTTP, so require a deliberate click.
    confirmation = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: true;
}
