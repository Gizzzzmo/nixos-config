{
  lib,
  config,
  ...
}: {
  security.pki.certificateFiles = [
    ../../certificates/headscale.crt
  ];

  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://headscale.jonbyr.com";
      noise.private_key_path = "/var/lib/headscale/noise_private.key";
      prefixes.v4 = "100.64.0.0/10";
      prefixes.v6 = "fd7a:115c:a1e0::/48";
      dns.magic_dns = true;
      dns.base_domain = "headscale.local";
      dns.override_local_dns = true;
      dns.nameservers.global = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
      database.sqlite.path = "/var/lib/headscale/db.sqlite";
      tls_cert_path = "/etc/headscale/headscale.crt";
      tls_key_path = "/etc/headscale/headscale.key";
      log.level = "info";
      ephemeral_node_inactivity_timeout = "30m";
    };
  };

  services.nginx.virtualHosts."headscale.jonbyr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:8080";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
      '';
    };
    extraConfig = ''
      access_log /var/log/nginx/headscale_access.log;
      error_log /var/log/nginx/headscale_error.log;
    '';
  };
}