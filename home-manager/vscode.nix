{ pkgs, config, ... }: {
  # programs.java.enable = true;
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {

      userSettings = {
        "git.openRepositoryInParentFolders" = "never";
        "extensions.ignoreRecommendations" = true;
        "keyboard.dispatch" = "keyCode";
      };

      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        redhat.java
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vadimcn.vscode-lldb
      ];
    };

  };


}
