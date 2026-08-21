{
  lib,
  config,
  pkgs,
  ...
}: {
  # Auto-mount Hetzner Storage Box via CIFS
  fileSystems."/home/jonas/mnt/storagebox" = {
    device = "//u610415.your-storagebox.de/backup";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=1000"
      "gid=100"
      "file_mode=0644"
      "dir_mode=0755"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  environment.systemPackages = [pkgs.cifs-utils];
}