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
      cmd =
        if standalone
        then [
          "clangd"
          "--resource-dir=/home/jonas/.cmaketoolchains/downloads/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04/lib/clang/18"
        ]
        else ["clangd"];
    };

    rust_analyzer = {
      enable = true;
      package = null;
      installCargo = false;
      installRustc = false;
    };

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
    # cmake = {
    #   enable = true;
    #   package = pkgs.cmake-language-server;
    # };

    basedpyright = {
      enable = true;
    };

    typos_lsp = {
      enable = true;
    };

    ltex = {
      enable = true;
    };

    tinymist = {
      enable = true;
      package = null;
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
  };

  keymaps = {
    diagnostic = {
      "<leader>j" = "goto_next";
      "<leader>k" = "goto_prev";
    };
    lspBuf = {
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };
  };
}
