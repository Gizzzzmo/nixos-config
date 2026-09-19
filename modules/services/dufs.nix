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

  # Root wrappers for the control panel (run via passwordless sudo, no
  # arguments allowed — secrets arrive on stdin so they never appear in
  # argv, shell history or logs).
  veracrypt-mount = pkgs.writeShellScript "storagebox-veracrypt-mount" ''
    set -eu

    volume="/mnt/storagebox-dufs/encrypted.vc"
    mountpoint="/mnt/storagebox-dufs/decrypted"

    if ${pkgs.util-linux}/bin/mountpoint -q "$mountpoint"; then
      echo "already mounted"
      exit 0
    fi

    IFS= read -r pw
    if [ -z "$pw" ]; then
      echo "no password provided"
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$mountpoint"
    printf '%s\n' "$pw" | ${pkgs.veracrypt}/bin/veracrypt -t \
      --non-interactive --stdin --pim=0 --protect-hidden=no -k "" \
      --fs-options=uid=499,gid=499,umask=007 \
      "$volume" "$mountpoint"
  '';

  veracrypt-unmount = pkgs.writeShellScript "storagebox-veracrypt-unmount" ''
    set -eu

    mountpoint="/mnt/storagebox-dufs/decrypted"

    if ! ${pkgs.util-linux}/bin/mountpoint -q "$mountpoint"; then
      echo "not mounted"
      exit 0
    fi

    exec ${pkgs.veracrypt}/bin/veracrypt -t --non-interactive --unmount "$mountpoint"
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
      "file_mode=0640"
      "dir_mode=0750"
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

  # Mount/unmount buttons for the encrypted container on the storagebox.
  # The password is entered in a hidden OliveTin input; OliveTin passes it
  # as the $PASSWORD environment variable (never a template placeholder, so
  # it can't end up in argv), the action pipes it through sudo's stdin, and
  # the root wrapper feeds it to veracrypt --stdin. The decrypted fs gets
  # uid/gid 499 (dufs) so the fileshare can serve it; umask=000 is the usual
  # shared-drive setup for FAT/exFAT.
  sys.controlPanel.actions.mountStorageboxCrypt = {
    title = "Mount storagebox crypt volume";
    exec = [
      "/bin/sh"
      "-c"
      ''printf '%s\n' "$PASSWORD" | ${pkgs.sudo}/bin/sudo ${veracrypt-mount}''
    ];
    sudoCommand = "${veracrypt-mount}";
    arguments = [
      {
        name = "password";
        type = "password";
        title = "VeraCrypt password";
      }
    ];
    icon = "&#128274;";
    timeout = 300;
  };

  sys.controlPanel.actions.unmountStorageboxCrypt = {
    title = "Unmount storagebox crypt volume";
    shell = "${pkgs.sudo}/bin/sudo ${veracrypt-unmount}";
    sudoCommand = "${veracrypt-unmount}";
    icon = "&#128275;";
    timeout = 300;
    # Fails loudly if files on the volume are in use; make it deliberate.
    confirmation = true;
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
