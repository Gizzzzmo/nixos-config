{
  pkgs,
  standalone,
  ...
} @ home_inputs: {
  enable = true;

  # colorschemes.lunaperche.enable = true;
  colorscheme = "lunaperche";

  highlightOverride = {
    IblIdent = {
      fg = "#080808";
    };
    WinSeparator = {
      fg = "#444444";
    };
    Comment = {
      fg = "#ffc244";
    };
    LineNr = {
      fg = "#ccddff";
    };
    LineNrAbove = {
      fg = "#7e7e7e";
    };
    LineNrBelow = {
      fg = "#7e7e7e";
    };
    # overwrites below are specifically meant for lunaperche
    Normal = {
      bg = "#0c1016";
    };
    "@variable.member" = {
      fg = "#ee8866";
    };
    "@lsp.type.property" = {
      fg = "#ffbb99";
    };
    "@property".link = "@lsp.type.property";
    "@variable.member".link = "@lsp.type.property";
    Type = {
      bold = true;
      fg = "#5fd75f";
    };
    "@keyword.type".link = "Statement";
    "@function.call" = {
      fg = "#6699dd";
    };
    "@variable.parameter" = {
      fg = "#cccc55";
    };
    "@lsp.type.parameter".link = "@variable.parameter";
    typstHashtagIdentifier.link = "@function.call";
    "@lsp.type.function.typst".link = "@function.call";
    "@markup.link.label.markdown_inline" = {
      fg = "#f584ff";
      underline = true;
    };
  };

  extraConfigLuaPre = ''
    -- require("vague").setup({})
  '';

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
    # "pack/blub/start/vague.nvim" = {
    #   enable = true;
    #   source = pkgs.fetchFromGitHub {
    #     owner = "vague2k";
    #     repo = "vague.nvim";
    #     rev = "v1.4.1";
    #     hash = "sha256-isROQFePz8ofJg0qa3Avbwh4Ml4p9Ii2d+VAAkbeGO8=";
    #   };
    # };
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
  };

  diagnostic.settings = {
    virtual_text = true;
    # float = {
    #   border = "rounded";
    # };
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
    copilot-lua = (import ./neovim/copilot-lua.nix) home_inputs;
    lsp = (import ./neovim/lsp.nix) home_inputs;
    blink-cmp = (import ./neovim/blink-cmp.nix) home_inputs;
    luasnip = (import ./neovim/luasnip.nix) home_inputs;
    telescope = (import ./neovim/telescope.nix) home_inputs;
    # lean = (import ./neovim/lean.nix) home_inputs;
    treesitter = (import ./neovim/treesitter.nix) home_inputs;
    tmux-navigator = (import ./neovim/tmux-navigator.nix) home_inputs;
    snacks = (import ./neovim/snacks.nix) home_inputs;
    neogen = (import ./neovim/neogen.nix) home_inputs;

    schemastore.enable = true;
    clangd-extensions.enable = true;
    rustaceanvim.enable = true;
    fzf-lua.enable = true;
    # cmp_luasnip.enable = true;
    diffview.enable = true;
    web-devicons.enable = true;
    nvim-surround.enable = true;
    ccc.enable = true;
    oil.enable = true;
    opencode.enable = true;
    gitgutter.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-gdb
    telescope-emoji-nvim
  ];

  dependencies = {
    git.enable = true;
  };
}
