{pkgs, ...}: {
  enable = true;
  package = pkgs.vimPlugins.lualine-nvim;
  settings = {
    options.component_separators = "│";
    options.section_separators = "";
    options.theme = "iceberg_dark";
    sections = {
      lualine_a = [
        {
          __unkeyed-1 = "git_branch";
          icon = "";
        }
        {
          __unkeyed-1 = "git_diff";
          colored = true;
          always_visible = false;
        }
      ];
      lualine_c = [
        {
          __unkeyed-1 = "filename";
          path = 1;
        }
      ];
      lualine_x = [
        {
          __unkeyed-1 = "filetype";
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
