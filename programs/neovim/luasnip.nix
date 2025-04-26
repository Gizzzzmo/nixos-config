{...}: {
  enable = true;
  fromLua = [
    {
      paths = "~/.config/nvim/snippets";
    }
  ];
  settings = {
    exit_roots = true;
    update_events = [
      "TextChanged"
      "TextChangedI"
    ];
  };
}
