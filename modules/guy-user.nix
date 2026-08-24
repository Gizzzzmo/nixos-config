{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    guy-user.enable = lib.mkEnableOption "enable user module";
  };

  config = lib.mkIf config.guy-user.enable {
    users.users.guy = {
      isNormalUser = true;
      initialPassword = "blub";
      description = "guy";
      shell = pkgs.bash;
      openssh.authorizedKeys.keyFiles = [../ssh-keys/guy_at_guy.pub];
      extraGroups = [
        "systemd-journal"
      ];
    };
  };
}
