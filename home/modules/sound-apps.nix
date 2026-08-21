{pkgs, ...}: {
  home.packages = with pkgs; [
    cmus
    wiremix
  ];
}
