{
  lib,
  config,
  pkgs,
  ...
}: {
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [pkgs.virtiofsd];
        swtpm = {
          enable = true;
          package = pkgs.swtpm;
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };

  users.groups.libvirtd = {};

  main-user.extraGroups = ["libvirtd"];

  environment.systemPackages = with pkgs; [
    swtpm
    tpm-tools
  ];
}