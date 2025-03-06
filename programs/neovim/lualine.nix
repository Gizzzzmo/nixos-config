{pkgs, ...}:
{
  enable = true;
  gitPackage = pkgs.git;
  package = pkgs.vimPlugins.lualine-nvim;
  settings = {
    options.theme = "palenight";
    sections = {
      lualine_c = [
        {
          __unkeyed-1 = "filename";
          path = 1;
        }
      ];
    };
    inactive_sections = {
      lualine_c = [
        {
          __unkeyed-1 = "filename";
          path = 1;
        }
      ];
    };
  };
}
