{
  lib,
  config,
  pkgs,
  ...
}: let
  mkbare = pkgs.writeShellScript "mkbare" ''
    exec ${pkgs.git}/bin/git init --bare -b main "/srv/git/$1"
  '';
in {
  users.groups.git = {
    gid = 997;
  };

  users.users.git = {
    isSystemUser = true;
    group = "git";
    uid = 998;
    home = "/home/git";
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
  };

  main-user.extraGroups = ["git"];

  fileSystems."/mnt/storagebox-git" = {
    device = "//u610415.your-storagebox.de/backup/git";
    fsType = "cifs";
    options = [
      "_netdev"
      "x-systemd.requires=network-online.target"
      "credentials=/home/jonas/shared/.smbcredentials-storagebox"
      "uid=998"
      "gid=997"
      "file_mode=0664"
      "dir_mode=0775"
      "iocharset=utf8"
      "noserverino"
    ];
  };

  system.activationScripts.git-server = ''
    mkdir -p /home/git/git-shell-commands
    rm -f /srv/git
    ln -s /mnt/storagebox-git /srv/git
    cp ${mkbare} /home/git/git-shell-commands/mkbare
    chmod 755 /home/git/git-shell-commands/mkbare
    chown -R git:git /home/git
  '';
}
