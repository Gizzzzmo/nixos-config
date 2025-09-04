{...}: {
  enable = true;
  extensions = {
    fzf-native.enable = true;
    frecency.enable = true;
    live-grep-args = {
      enable = true;
      settings = {
        auto_quoting = true;
        mappings = {
          i = {
            "<C-i>".__raw = "require('telescope-live-grep-args.actions').quote_prompt({postfix = ' --iglob '})";
            "<C-j>".__raw = "require('telescope-live-grep-args.actions').quote_prompt()";
            "<C-space>".__raw = "require('telescope.actions').to_fuzzy_refine";
          };
        };
      };
    };
  };

  settings.pickers.find_files.hidden = true;

  settings.defaults = {
    file_ignore_patterns = [
      "^.git/.*"
      "^.jj/.*"
      ".cache/.*"
      ".venv/.*"
    ];
    cache_picker = {
      num_pickers = 15;
    };
  };
}
