{ lib, pkgs, ... }: {
  home.username = "chris";
  home.homeDirectory = "/home/chris";

  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "24.11";

  home.pointerCursor.enable = true;

  home.sessionVariables = {
    ZSH_GH_COPILOT_NO_CHECK=1;
    PAGER="nvimpager";
  };
  
  programs.home-manager.enable = true;

  home.file = 
    let toRecursive = item: {
            source = ./. + "/config/${item}";
            recursive = true;
    };
    in {
      ".config/vifm"         = toRecursive "vifm";
      ".config/yazi"         = toRecursive "yazi";
      ".config/way-displays" = toRecursive "way-displays";
    };

  imports = [ 
    ./ai.nix
    ./davmail.nix
    ./eilmeldung.nix
    ./firefox.nix
    ./fonts.nix
    ./foot.nix
    ./fuzzel.nix
    ./git.nix 
    ./gpg-pass.nix
    ./mail.nix
    ./mbsync.nix
    ./mime-apps.nix
    ./misc.nix
    ./neomutt.nix
    ./neovim.nix
    ./user-packages.nix
    ./ssh.nix
    ./stylix.nix
    ./mango.nix
    ./vscode.nix
    ./waybar.nix
    ./yazi.nix
    ./zellij.nix
    ./zsh.nix
  ];
}
