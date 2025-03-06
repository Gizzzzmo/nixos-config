{...}:
{
  enable = true;
  extensions = {
    fzf-native.enable = true;
  };

  enabledExtensions = [
    "advanced_git_search"
  ];

  settings.pickers.find_files.hidden = true;

  settings.defaults = {
    file_ignore_patterns = [
      "^.git/"
      ".cache/"
      ".venv/"
    ];
  };
}
