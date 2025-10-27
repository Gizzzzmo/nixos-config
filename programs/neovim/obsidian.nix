{
  pkgs,
  standalone,
  ...
}: {
  enable = true;
  package = pkgs.vimPlugins.obsidian-nvim;
  settings = {
    legacy_commands = false;
    note_id_func = ''
      function(title)
        return title
      end
    '';
    note_path_func = ''
      function(spec)
        local path = spec.dir / spec.title
        return path:with_suffix(".md")
      end
    '';
    follow_img_func = ''
      function(url)
        vim.fn.jobstart({"xdg-open", url})
      end
    '';
    follow_url_func = ''
      function(url)
        vim.fn.jobstart({"xdg-open", url})
      end
    '';
    markdown_link_func = ''
      function(opts)
        return string.format("[%s](%s)", opts.label, opts.path)
      end
    '';

    daily_notes = {
      date_format = "%Y-%m-%d";
      folder = "./daily";
    };

    completion = {
      min_chars = 2;
      blink = true;
    };

    new_notes_location = "current_dir";

    workspaces =
      (
        if standalone
        then [
          {
            name = "siemens";
            path = "~/gitprjs/siemens/documentation/notes/";
          }
        ]
        else []
      )
      ++ [
        {
          name = "notes";
          path = "~/notes/notes/";
        }
        {
          name = "website";
          path = "~/gitprjs/personal/website/site";
        }
      ];
  };
}
