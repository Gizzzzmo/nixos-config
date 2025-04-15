{pkgs, ...}: {
  enable = true;
  package = pkgs.vimPlugins.fugitive;
  gitPackage = pkgs.git;
}
