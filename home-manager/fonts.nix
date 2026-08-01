{ config, pkgs, lib, ... } : {

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [  "DejaVu Serif" ];
      sansSerif = [ "Figtree"  ];
      monospace = [ "SauceCodePro Nerd Font Mono" ];
    };

  };
  home.packages = with pkgs; [
    cantarell-fonts
    freefont_ttf
    ubuntu-classic
    liberation_ttf
    nerd-fonts.hack
    nerd-fonts.sauce-code-pro
    noto-fonts-color-emoji
    font-awesome
    dejavu_fonts
    corefonts
    vista-fonts
    jost
    figtree
    fira-sans
    nerd-fonts.fira-code
    adwaita-fonts
  ];

}


