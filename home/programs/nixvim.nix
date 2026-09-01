{pkgs, ...} @ home_inputs: {
  enable = true;

  # colorschemes.lunaperche.enable = true;
  colorscheme = "my-lunaperche";

  opts = {
    diffopt = "vertical";
    undofile = true;
    number = true;
    relativenumber = true;
    shiftwidth = 4;
    expandtab = true;
    scrolloff = 12;
    signcolumn = "yes";
    conceallevel = 1;
    pumheight = 7;
    tabstop = 4;
    foldlevel = 99;
  };

  globals.mapleader = " ";

  extraFiles = {
    "colors/my-lunaperche.vim" = {
      enable = true;
      source = ./neovim/colors/my-lunaperche.vim;
    };
    "lua/prox-telescope.lua" = {
      enable = true;
      source = ./neovim/lua/prox-telescope.lua;
    };
    "lua/ast-grep.lua" = {
      enable = true;
      source = ./neovim/lua/ast-grep.lua;
    };
    "lua/obsidian-helper.lua" = {
      enable = true;
      source = ./neovim/lua/obsidian-helper.lua;
    };
    "lua/git-ref-picker.lua" = {
      enable = true;
      source = ./neovim/lua/git-ref-picker.lua;
    };
  };

  diagnostic.settings = {
    virtual_text = true;
  };

  clipboard.providers.wl-copy = {
    enable = true;
    package = pkgs.wl-clipboard;
  };

  autoCmd = import ./neovim/auto-commands.nix;

  keymaps = import ./neovim/keymaps.nix;
  plugins = {
    aerial = (import ./neovim/aerial.nix) home_inputs;
    zen-mode = (import ./neovim/zen-mode.nix) home_inputs;
    indent-blankline = (import ./neovim/indent-blankline.nix) home_inputs;
    lualine = (import ./neovim/lualine.nix) home_inputs;
    fugitive = (import ./neovim/fugitive.nix) home_inputs;
    obsidian = (import ./neovim/obsidian.nix) home_inputs;
    llm = (import ./neovim/llm.nix) home_inputs;
    copilot-lua = (import ./neovim/copilot-lua.nix) home_inputs;
    blink-cmp = (import ./neovim/blink-cmp.nix) home_inputs;
    luasnip = (import ./neovim/luasnip.nix) home_inputs;
    telescope = (import ./neovim/telescope.nix) home_inputs;
    # lean = (import ./neovim/lean.nix) home_inputs;
    treesitter = (import ./neovim/treesitter.nix) home_inputs;
    tmux-navigator = (import ./neovim/tmux-navigator.nix) home_inputs;
    snacks = (import ./neovim/snacks.nix) home_inputs;
    iron = (import ./neovim/iron.nix) home_inputs;

    # lsp stuff
    lsp = (import ./neovim/lsp.nix) home_inputs;
    clangd-extensions.enable = true;
    rustaceanvim.enable = true;
    typescript-tools.enable = true;

    schemastore.enable = true;
    fzf-lua.enable = true;
    # cmp_luasnip.enable = true;
    diffview.enable = true;
    web-devicons.enable = true;
    nvim-surround.enable = true;
    ccc.enable = true;
    oil.enable = true;
    opencode.enable = true;
    gitgutter = {
      enable = true;
      settings = {
        map_keys = 0;
      };
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-gdb
    telescope-emoji-nvim
  ];

  dependencies = {
    git.enable = true;
    llm-ls = {
      enable = true;
      package = pkgs.llm-ls.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            # ./neovim/patches/llm-ls-keep-multiline.patch
            ./neovim/patches/llm-ls-utf16.patch
          ];
      });
    };
  };
}
