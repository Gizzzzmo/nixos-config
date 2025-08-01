{pkgs, ...}: {
  enable = true;
  package = pkgs.vimPlugins.lualine-nvim;
  settings = {
    options.component_separators = "│";
    options.section_separators = "";
    options.theme = "iceberg_dark";
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
