{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    main-user.enable = lib.mkEnableOption "enable user module";
  };

  config = lib.mkIf config.main-user.enable {
    users.users.guy = {
      isNormalUser = true;
      initialPassword = "blub";
      description = "guy";
      shell = pkgs.bash;
      sshKeyFiles = [ ../ssh-keys/guy@guy.pub ];
      extraGroups = [
        "systemd-journal"
      ];
    };
  };
}
