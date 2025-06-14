[
  {
    command = "setfiletype markdown";
    event = ["BufRead" "BufNewFile"];
    pattern = "*.mdx";
  }
  {
    command = "nnoremap <buffer> <C-c> i<C-c>";
    event = "TermOpen";
    pattern = "*";
  }

  # codeformatting might replace these with none-ls at some point
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

  # obsidian workspaces
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

  # nix tab settings
  {
    command = ":setlocal tabstop=2 shiftwidth=2 expandtab";
    event = "BufEnter";
    pattern = "*.nix";
  }

  # markdown line wrapping
  {
    command = ":setlocal linebreak breakindent";
    event = "BufEnter";
    pattern = "*.md";
  }

  # C, C++ commentstring
  {
    command = ":setlocal commentstring=//\\ %s";
    event = "FileType";
    pattern = "c,cpp";
  }

  # when opening any buffer go to last cursor position
  {
    command = "silent! normal! g`\"zv";
    event = "BufReadPost";
    pattern = "*";
  }
]
