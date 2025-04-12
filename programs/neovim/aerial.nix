{ standalone, ... }:
{
  enable = !standalone;
  settings = {
    attach_mode = "global";
    autojump = true;
    layout = {
      min_width = [ 20 ];
      max_width = [ 20 ];
    };
    backends = [
      "lsp"
      "treesitter"
      "markdown"
      "asciidoc"
      "man"
    ];
  };
}
