{
  standalone,
  pkgs,
  ...
}: {
  enable = true;
  grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
    nix
    make
    json
    bash
    vim
    lua
    toml
    yaml
    cpp
    zig
    c
    cmake
    toml
    rust
    markdown
    python
  ];
  folding =
    if standalone
    then true
    else {enable = true;};
  settings = {
    highlight.enable = true;
    incremental_selection = {
      enable = true;
      keymaps = {
        node_incremental = "L";
        node_decremental = "H";
      };
    };
  };
}
