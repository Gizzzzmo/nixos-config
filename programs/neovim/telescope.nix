{...}: {
  enable = true;
  extensions = {
    fzf-native.enable = true;
  };

  settings.pickers.find_files.hidden = true;

  settings.defaults = {
    file_ignore_patterns = [
      "^.git/.*"
      "^.jj/.*"
      ".cache/.*"
      ".venv/.*"
    ];
  };
}
