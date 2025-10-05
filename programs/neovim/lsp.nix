{
  pkgs,
  standalone,
  ...
}: {
  enable = true;
  inlayHints = true;
  preConfig = ''
    local border = {
      { '┌', 'FloatBorder' }, { '─', 'FloatBorder' },
      { '┐', 'FloatBorder' },
      { '│', 'FloatBorder' },
      { '┘', 'FloatBorder' },
      { '─', 'FloatBorder' },
      { '└', 'FloatBorder' },
      { '│', 'FloatBorder' },
    };
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = border
      }
    )
  '';

  servers = {
    clangd = {
      enable = true;
      package = null;
      cmd = ["clangd"];
    };

    # Will wait for mdx_analyzer package to become available in nixpkgs
    # mdx_analyzer = {
    #   enable = true;
    #   package = null;
    #   cmd = ["/home/jonas/npmpkgs/node_modules/.bin/mdx-language-server" "--stdio"];
    #   filetypes = ["markdown"];
    # };

    # mojo = {
    #   enable = true;
    #   package = null;
    # };

    # rust_analyzer = { enable = true;
    #   package = null;
    #   cmd = ["rust-analyzer"];
    #   installCargo = false;
    #   installRustc = false;
    # };

    neocmake = {
      enable = true;
      package = null;
      extraOptions = {
        capabilities.textDocument.completion.completionItem.snippetSupport = false;
        init_options = {
          format = {
            enable = false;
          };
          lint = {
            enable = false;
          };
        };
      };
    };

    basedpyright = {
      enable = true;
      package = null;
    };

    typos_lsp = {
      enable = true;
    };

    ltex = {
      enable = false;
    };

    tinymist = {
      enable = true;
      package = null;
      settings = {
        formatterMode = "typstyle";
        formatterPrintWidth = 100;
        exportPdf = "onType";
      };
    };

    zls = {
      enable = true;
      package = null;
    };

    nixd = {
      enable = true;
    };

    lua_ls = {
      enable = true;
    };

    cssls = {
      enable = true;
      package = null;
    };

    bashls = {
      enable = true;
    };

    fish_lsp = {
      enable = true;
    };

    jsonls = {
      enable = true;
    };

    gopls = {
      enable = true;
      package = null;
    };

    yamlls = {
      enable = true;
      filetypes = [
        "yaml"
      ];
    };
  };

  keymaps = {
    diagnostic = {
      "<leader>j" = "goto_next";
      "<leader>h" = "goto_prev";
    };
    lspBuf = {
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };
  };
}
