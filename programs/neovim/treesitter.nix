{ pkgs, ... }:
{
  enable = true;
  settings = {
    highlight.enable = true;
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
      c
      cmake
      toml
      rust
      markdown
    ];
    incremental_selection = {
      enable = true;
      keymaps = {
        node_incremental = "L";
        node_decremental = "H";
      };
    };
  };
}
