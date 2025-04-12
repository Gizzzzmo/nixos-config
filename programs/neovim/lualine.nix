{ pkgs, ... }:
{
  enable = true;
  gitPackage = pkgs.git;
  package = pkgs.vimPlugins.lualine-nvim;
  settings = {
    options.component_separators = "│";
    options.section_separators = "";
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
