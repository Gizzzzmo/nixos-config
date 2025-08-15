{pkgs, ...}: {
  enable = true;

  profiles.default = {
    extensions = with pkgs.vscode-extensions; [
      # rust-lang.rust-analyzer
      eamodio.gitlens
      #vscodevim.vim
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      enkia.tokyo-night
    ];
    userSettings = {
      "[nix]"."editor.tabSize" = 2;
      "editor.stickyScroll.enabled" = false;
      "editor.fontFamily" = "FiraCode Nerd Font";
      "editor.fontSize" = 14;
      "extensions.ignoreRecommendations" = true;
      "cmake.showOptionsMovedNotification" = false;
      "cmake.showNotAllDocumentsSavedQuestion" = false;
      "cmake.pinnedCommands" = [
        "workbench.action.tasks.configureTaskRunner"
        "workbench.action.tasks.runTask"
      ];
      "update.mode" = "none";
      "workbench.colorTheme" = "Tokyo Night Pure";
      "window.menuBarVisibility" = "toggle";
    };
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };
  # keybindings are in dotfiles/.config/Code/User/keybindings.json
}
