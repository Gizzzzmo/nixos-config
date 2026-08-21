{
  lib,
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    host = config.sys.bindAddress;
  };
}