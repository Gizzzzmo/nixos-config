{...}: {
  enable = true;
  settings = {
    attach_mode = "global";
    autojump = true;
    layout = {
      min_width = [20];
      max_width = [20];
    };
    backends = {
      "_" = [
        "lsp"
        "treesitter"
        "markdown"
        "asciidoc"
        "man"
      ];
      markdown = ["treesitter" "markdown"];
    };
    # filter_kind = false;
  };
}
