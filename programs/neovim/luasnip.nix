{...}: {
  enable = true;
  fromLua = [
    {
      paths = ./snippets/lua;
    }
  ];
  fromVscode = [
    {
      paths = [./snippets/vscode "~/.config/snippets/vscode"];
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
