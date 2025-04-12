{ pkgs, standalone, ... }:
{
  enable = true;
  inlayHints = true;
  preConfig = ''
    local border = {
      { '┌', 'FloatBorder' },
      { '─', 'FloatBorder' },
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
        if standalone then
          [
            "clangd"
            "--resource-dir=/home/jonas/.cmaketoolchains/downloads/clang+llvm-18.1.8-x86_64-linux-gnu-ubuntu-18.04/lib/clang/18"
          ]
        else
          [ "clangd" ];
    };

    rust_analyzer = {
      enable = true;
      installCargo = false;
      installRustc = false;
    };

    cmake = {
      enable = true;
      package = pkgs.cmake-language-server;
    };

    pyright = {
      enable = true;
      package = pkgs.pyright;
    };

    typos_lsp = {
      enable = true;
    };

    tinymist = {
      enable = true;
    };

    zls = {
      enable = true;
    };

    nixd = {
      enable = true;
    };

    cssls = {
      enable = true;
    };

    bashls = {
      enable = true;
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
