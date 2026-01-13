{
  pkgs,
  standalone,
  ...
}: {
  enable = true;
  package = pkgs.vimPlugins.obsidian-nvim;
  settings = {
    legacy_commands = false;
    note_id_func.__raw = ''
      function(title)
        return title
      end
    '';
    note_path_func.__raw = ''
      function(spec)
        local path = spec.dir / spec.id
        return path:with_suffix(".md")
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
          path = "/home/jonas/notes/notes/";
        }
        {
          name = "website";
          path = "/home/jonas/gitprjs/personal/website/site";
        }
      ];
  };
}
