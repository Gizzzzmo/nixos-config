{pkgs, ...} @ home_inputs: {
  enable = true;

  colorschemes.tokyonight.enable = true;

  highlightOverride = {
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
  };

  opts = {
    diffopt = "vertical";
    number = true;
    relativenumber = true;
    shiftwidth = 4;
    expandtab = true;
    scrolloff = 12;
    signcolumn = "number";
    conceallevel = 1;
    pumheight = 7;
    tabstop = 4;
    foldlevel = 99;
  };

  globals.mapleader = " ";

  extraFiles = {
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

  # extraFiles."snippets/" = {
  #   enable = true;
  #   source = ./neovim/snippets;
  # };

  diagnostic.settings = {
    float = {
      border = "rounded";
    };
  };

  clipboard.providers.wl-copy = {
    enable = true;
    package = pkgs.wl-clipboard;
  };

  autoCmd = import ./neovim/auto-commands.nix;

  keymaps = import ./neovim/keymaps.nix;

  plugins.aerial = (import ./neovim/aerial.nix) home_inputs;
  plugins.zen-mode = (import ./neovim/zen-mode.nix) home_inputs;
  plugins.indent-blankline = (import ./neovim/indent-blankline.nix) home_inputs;
  plugins.lualine = (import ./neovim/lualine.nix) home_inputs;
  plugins.fugitive = (import ./neovim/fugitive.nix) home_inputs;
  plugins.obsidian = (import ./neovim/obsidian.nix) home_inputs;
  plugins.copilot-lua = (import ./neovim/copilot-lua.nix) home_inputs;
  plugins.lsp = (import ./neovim/lsp.nix) home_inputs;
  plugins.cmp = (import ./neovim/cmp.nix) home_inputs;
  plugins.luasnip = (import ./neovim/luasnip.nix) home_inputs;
  plugins.telescope = (import ./neovim/telescope.nix) home_inputs;
  plugins.lean = (import ./neovim/lean.nix) home_inputs;
  plugins.treesitter = (import ./neovim/treesitter.nix) home_inputs;
  plugins.avante = (import ./neovim/avante.nix) home_inputs;

  plugins.fzf-lua.enable = true;
  plugins.cmp_luasnip.enable = true;
  plugins.copilot-chat.enable = true;
  plugins.diffview.enable = true;
  plugins.web-devicons.enable = true;
  plugins.nvim-surround.enable = true;
  plugins.ccc.enable = true;
  plugins.refactoring.enable = true;
  plugins.tmux-navigator = {
    enable = true;
    keymaps = [
      {
        mode = ["n" "i"];
        action = "left";
        key = "<M-h>";
      }
      {
        mode = ["n" "i"];
        action = "down";
        key = "<M-j>";
      }
      {
        mode = ["n" "i"];
        action = "up";
        key = "<M-k>";
      }
      {
        mode = ["n" "i"];
        action = "right";
        key = "<M-l>";
      }
      {
        mode = ["n" "i"];
        action = "previous";
        key = "<C-\\>";
      }

    ];
    settings.no_mappings = 1;
  };

  plugins.oil = {
    enable = true;
    # settings = {
    #   win_optinos = {
    #     signcolumn = "yes:2";
    #   };
    # };
  };

  extraPlugins = with pkgs.vimPlugins; [
    nvim-gdb
    advanced-git-search-nvim
    telescope-emoji-nvim
  ];

  # plugins.texpresso = {
  #   enable = !standalone;
  # };
  dependencies = {
    git.enable = true;
  };
}
