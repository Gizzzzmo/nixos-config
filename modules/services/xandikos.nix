{...}: let
  # Loopback only; nginx (below) terminates TLS + auth for the public vhost.
  port = 8082;
in {
  services.xandikos = {
    enable = true;
    address = "127.0.0.1";
    inherit port;
    routePrefix = "/";
    # Create a default calendar + addressbook under the /user/ principal on
    # first start so clients can autodiscover (RFC 5397) immediately.
    extraOptions = [
      "--autocreate"
      "--defaults"
    ];
  };

  # Data dir is /var/lib/xandikos (StateDirectory, mode 0700, owned by the
  # dynamic `xandikos` user). Git-backed: back it up by rsyncing the whole
  # directory (candidate for the storage-box sync, like /srv/git).
  services.nginx.virtualHosts."calendar.jonbyr.com" = {
    enableACME = true;
    forceSSL = true;

    # Basic auth at the proxy. Credentials live OUTSIDE the nix store
    # (same pattern as /etc/tuwunel-registration-token):
    #   sudo nix shell nixpkgs#apacheHttpd -c htpasswd -B -c /etc/xandikos-htpasswd jonas
    #   sudo nix shell nixpkgs#apacheHttpd -c htpasswd -B /etc/xandikos-htpasswd guy
    # (drop -c for entries after the first). File must be readable by nginx:
    #   sudo chown root:nginx /etc/xandikos-htpasswd && sudo chmod 640 /etc/xandikos-htpasswd
    basicAuthFile = "/etc/xandikos-htpasswd";

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 300s;
      '';
    };

    # Well-known discovery: point legacy autoconfig paths at the
    # current-user-principal (must be reachable without auth for clients
    # that probe it before presenting credentials).
    locations."= /.well-known/caldav".return = "301 /user/";
    locations."= /.well-known/carddav".return = "301 /user/";

    extraConfig = ''
      limit_req zone=calendar_limit burst=20 nodelay;
      access_log /var/log/nginx/calendar_access.log;
      error_log /var/log/nginx/calendar_error.log;
    '';
  };

  services.nginx.commonHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=calendar_limit:5m rate=10r/s;
  '';
}
