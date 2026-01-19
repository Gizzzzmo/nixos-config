{...}: {
  enable = true;
  theme = builtins.readFile ./gitui/theme.ron;
  keyConfig = builtins.readFile ./gitui/key_bindings.ron;
}
