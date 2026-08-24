{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    guy-user.enable = lib.mkEnableOption "enable user module";
    guy.userName = lib.mkOption {
      type = lib.types.str;
      default = "mainuser";
      description = "Username.";
    };
    guy.extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra groups for the main user (merged from all imported modules).";
    };
  };

  config = lib.mkIf config.main-user.enable {
    users.users.${config.main-user.userName} = {
      isNormalUser = true;
      initialPassword = "blub";
      description = "main user";
      shell = pkgs.fish;
      extraGroups =
        [
          "audio"
          "pipewire"
          "wheel"
          "networkmanager"
          "backlight"
          "input"
          "systemd-journal"
        ]
        ++ config.main-user.extraGroups;
    };
  };
}
