{
  lib,
  config,
  pkgs,
  ...
}: {
  services.udisks2.enable = true;

  # Allow user jonas to mount/unmount drives without password
  security.polkit.extraConfig = builtins.readFile ../../polkit-rules/mount-permissions.js;

  # Allow non-root users to use FUSE for sshfs mounting
  programs.fuse.userAllowOther = true;

  users.groups.storage = {};

  main-user.extraGroups = ["storage"];

  environment.systemPackages = with pkgs; [
    udisks
    sshfs
    ntfs3g
    exfat
  ];
}