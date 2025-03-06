{pkgs, ...}:
{
  enable = true;
  package = pkgs.vimPlugins.lean-nvim;
  settings = {
    mappings = true;
    lsp = {
      enable = true;
    };
  };
}
