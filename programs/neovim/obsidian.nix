{
  pkgs,
  standalone,
  ...
}: {
  enable = true;
  package = pkgs.vimPlugins.obsidian-nvim;
  settings = {
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

    callbacks = {
      enter_note = ''
        function(_, note)
          vim.keymap.set("n", "gf", "<cmd>Obsidian follow_link<cr>", {
            buffer = note.bufnr,
            desc = "Go to file",
          })
          vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
            buffer = note.bufnr,
            desc = "Toggle checkbox",
          })
        end
      '';
    };

    ui = {
      checkboxes = {
        " " = {
          char = "󰄱";
          hl_group = "ObsidianTodo";
        };
        ">" = {
          char = "";
          hl_group = "ObsidianRightArrow";
        };
        x = {
          char = "";
          hl_group = "ObsidianDone";
        };
        "~" = {
          char = "󰰱";
          hl_group = "ObsidianTilde";
        };
      };
    };

    completion = {
      min_chars = 2;
      nvim_cmp = true;
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
          name = "blog";
          path = "~/gitprjs/personal/blog/content/";
        }
      ];
  };
}
