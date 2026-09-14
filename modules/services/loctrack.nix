{pkgs, ...}: let
  loctrack-bin = pkgs.writeShellScriptBin "loctrack-bin.sh" ''
    LOCATION_INGEST_TOKEN=$(cat /etc/loctrack/token) ${pkgs.python3}/bin/python3 ${./loctrack_ingest.py}
  '';
in {
  users.groups.loctrack = {
    gid = 495;
  };

  users.users.loctrack = {
    isSystemUser = true;
    uid = 495;
    group = "loctrack";
    home = "/mnt/storagebox-loctrack";
    shell = "${pkgs.shadow}/bin/nologin";
  };

  main-user.extraGroups = ["loctrack"];

  fileSystems."/mnt/storagebox-loctrack" = {
    device = "//u610415.your-storagebox.de/backup/loctrack";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=495"
      "gid=495"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  systemd.services.loctrack = {
    description = "Location track POST server for loc.jonbyr.com";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    restartIfChanged = true;
    serviceConfig = {
      Type = "simple";
      User = "loctrack";
      Group = "loctrack";
      ExecStart = "${loctrack-bin}/bin/loctrack-bin.sh";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      ReadWritePaths = ["/mnt/storagebox-loctrack"];
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "loctrack";
    };
  };

  services.nginx.virtualHosts."loc.jonbyr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8443";
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 100M;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
      '';
    };
    extraConfig = ''
      limit_req zone=loctrack_limit burst=20 nodelay;
      access_log /var/log/nginx/loctrack_access.log;
      error_log /var/log/nginx/loctrack_error.log;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Referrer-Policy "no-referrer-when-downgrade" always;
    '';
  };

  services.nginx.commonHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=loctrack_limit:5m rate=10r/s;
  '';
}
