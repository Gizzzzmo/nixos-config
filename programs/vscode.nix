{pkgs, ...}:
{
  enable = true;
  extensions = with pkgs.vscode-extensions; [
    rust-lang.rust-analyzer
    eamodio.gitlens
    #vscodevim.vim
    jnoortheen.nix-ide
    llvm-vs-code-extensions.vscode-clangd
    ms-vscode.cmake-tools
    enkia.tokyo-night
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # binascii.hexlify(base64.b64decode('8QQmTUIxQZo3owpCNh+5IjtnoNNvd0M1FI3cJrFG5Rg=')).decode("utf-8")
    #
    # codeium tries to download its own language server binary which is incompatible with nix's non-fsh compliant filesystem, and it seems to be impossible to point the extension to another location for the language server binary
    #{
    #  name = "codeium";
    #  publisher = "Codeium";
    #  version = "1.17.4";
    #  sha256 = "bafae9048f2d7143fae122f5dd4400c2da3ee06614d131b4fb7bb79aa4c8869e";
    #}
    {
      name = "cmake-language-support-vscode";
      publisher = "josetr";
      version = "0.0.9";
      sha256 = "2cdb57619eb92e46b5969c5e2a8ccae8b074c9ac408c7b1f56c089f082d7f22a";
    }
  ];

  userSettings = {
    "[nix]"."editor.tabSize" = 2;
    "editor.stickyScroll.enabled" = false;
    "editor.fontFamily" = "FiraCode Nerd Font";
    "editor.fontSize" = 14;
    "extensions.ignoreRecommendations" = true;
    "cmake.showOptionsMovedNotification" = false;
    "cmake.showNotAllDocumentsSavedQuestion" = false;
    "cmake.pinnedCommands"= [
      "workbench.action.tasks.configureTaskRunner"
      "workbench.action.tasks.runTask"
    ];
    "update.mode"= "none";
    "workbench.colorTheme" = "Tokyo Night Pure";
    "window.menuBarVisibility" = "toggle";
  }; # keybindings are in dotfiles/.config/Code/User/keybindings.json
  enableExtensionUpdateCheck = false;
  enableUpdateCheck = false;
}
