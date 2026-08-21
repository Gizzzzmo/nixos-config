{
  lib,
  config,
  pkgs,
  ...
}: let
  dufs-merge-auth =
    pkgs.writers.writePython3Bin "dufs-merge-auth"
    {
      libraries = [pkgs.python3Packages.pyyaml];
    }
    ''
      import os
      import sys
      import tempfile

      import yaml

      CONFIG_BASE = "${../../dufs-config.yaml}"
      CONFIG_AUTH = "/etc/dufs/credentials.yaml"

      with open(CONFIG_BASE) as f:
          config = yaml.safe_load(f)

      if os.path.exists(CONFIG_AUTH):
          with open(CONFIG_AUTH) as f:
              auth_data = yaml.safe_load(f)
          if isinstance(auth_data, list):
              config["auth"] = auth_data

      tmp = tempfile.NamedTemporaryFile(
          prefix="dufs-", suffix=".yaml", mode="w", delete=False
      )
      yaml.dump(config, tmp)
      tmp.close()

      dufs = "${pkgs.dufs}/bin/dufs"
      os.execvp(dufs, [dufs, "--config", tmp.name] + sys.argv[1:])
    '';
in {
  users.groups.dufs = {
    gid = 499;
  };

  users.users.dufs = {
    isSystemUser = true;
    uid = 499;
    group = "dufs";
    home = "/mnt/storagebox-dufs";
    shell = "${pkgs.shadow}/bin/nologin";
  };

  main-user.extraGroups = ["dufs"];

  fileSystems."/mnt/storagebox-dufs" = {
    device = "//u610415.your-storagebox.de/backup/fileshare";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=499"
      "gid=499"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  systemd.services.dufs-fileshare = {
    description = "Dufs file server for fileshare.jonbyr.com";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    restartIfChanged = false;
    serviceConfig = {
      Type = "simple";
      User = "dufs";
      Group = "dufs";
      ExecStart = "${dufs-merge-auth}/bin/dufs-merge-auth";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      ReadWritePaths = ["/mnt/storagebox-dufs"];
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "dufs-fileshare";
    };
  };

  services.nginx.virtualHosts."fileshare.jonbyr.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8081";
      proxyWebsockets = true;
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
      limit_req zone=fileshare_limit burst=20 nodelay;
      access_log /var/log/nginx/fileshare_access.log;
      error_log /var/log/nginx/fileshare_error.log;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Referrer-Policy "no-referrer-when-downgrade" always;
    '';
  };

  services.nginx.commonHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=fileshare_limit:5m rate=10r/s;
  '';
}