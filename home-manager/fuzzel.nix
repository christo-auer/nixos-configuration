{ config, pkgs, lib, ... } : {

  home.file.".config/fuzzel" = {
    source = ./config/fuzzel;
    recursive = true;
  };

  programs.fuzzel = {
    enable = true;

    settings = {

      main = {
          terminal = "${pkgs.foot}/bin/foot";
          width = 80;
          use-bold  = true;
          
      };

    };

      
  };

}
