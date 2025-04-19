[
  {
    command = ":setlocal commentstring=//\\ %s";
    event = "FileType";
    pattern = "c,cpp";
  }

  {
    command = ":lua=vim.lsp.buf.format()";
    event = "BufWritePre";
    pattern = [
      "*.c"
      "*.h"
      "*.cpp"
      "*.hpp"
      "*.cc"
      "*.hh"
      "*.go"
    ];
  }

  {
    command = ":!test -f alejandra.toml && alejandra '%'";
    event = "BufWritePost";
    pattern = ["*.nix"];
  }

  {
    command = ":!test -f .editorconfig && shfmt -w '%'";
    event = "BufWritePost";
    pattern = ["*.sh"];
  }

  {
    command = ":!test -f .gersemirc && gersemi -i '%'";
    event = "BufWritePost";
    pattern = [
      "*.cmake"
      "CMakeLists.txt"
    ];
  }

  {
    command = ":!test -f .mdformat.toml && mdformat '%'";
    event = "BufWritePost";
    pattern = ["*.md"];
  }

  {
    command = ":!ruff format '%'";
    event = "BufWritePost";
    pattern = ["*.py"];
  }

  {
    command = ":setlocal tabstop=2 shiftwidth=2 expandtab";
    event = "BufEnter";
    pattern = "*.nix";
  }

  {
    command = ":ObsidianWorkspace siemens-notes";
    event = "BufEnter";
    pattern = "/home/jonas/gitprjs/siemens/documentation/notes/**";
  }

  {
    command = ":ObsidianWorkspace blog";
    event = "BufEnter";
    pattern = "/home/jonas/gitprjs/personal/blog/**";
  }

  {
    command = ":setlocal linebreak breakindent";
    event = "BufEnter";
    pattern = "*.md";
  }
]
