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

  networking.firewall.allowedTCPPorts = [80 443];

  nixpkgs.config.allowUnfreePredicate = pkg: true;
}