{pkgs, ...}: {
  imports = [
    ../core.nix
    ../modules/openviking.nix
  ];

  hm = {
    standalone = true;
    wsl = true;
  };

  home.packages = with pkgs; [
    cmake
    neocmakelsp
    basedpyright
    just
    zathura
    eog
    nodejs
  ];
}
