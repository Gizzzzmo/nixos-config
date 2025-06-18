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
    enable_autosnippets = true;
    exit_roots = true;
    update_events = [
      "TextChanged"
      "TextChangedI"
    ];
  };
}
