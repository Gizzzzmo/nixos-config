{
  lib,
  config,
  ...
}: {
  services.matrix-conduit = {
    enable = true;
    settings = {
      global = {
        port = 34751;
        address = config.sys.bindAddress;
        server_name = config.networking.hostName;
        allow_registration = true;
        allow_federation = false;
      };
    };
  };
}