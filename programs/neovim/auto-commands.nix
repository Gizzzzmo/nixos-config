[
  {
    command = ":setlocal commentstring=//\\ %s";
    event = "FileType";
    pattern = "c,cpp";
  }

  {
    command = ":lua=vim.lsp.buf.format()";
    event = "BufWritePre";
    pattern = ["*.c" "*.h" "*.cpp" "*.hpp" "*.cc" "*.hh"];
  }

  {
    command = ":!test -f .mdformat.toml && mdformat %";
    event = "BufWritePost";
    pattern = ["*.md"];
  }

  {
    command = ":!ruff format %";
    event = "BufWritePost";
    pattern = ["*.py"];
  }

  {
    command = ":setlocal tabstop=2 shiftwidth=2 expandtab";
    event = "BufEnter"; 
    pattern = "*.nix";
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
