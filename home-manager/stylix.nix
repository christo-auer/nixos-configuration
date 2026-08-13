{ config, pkgs, lib, ... } : {

  # gtk.gtk4.theme = null;

  stylix = {

    enable = true;
    autoEnable = true;
    enableReleaseChecks = false;


    # polarity = "dark";
    
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-mirage.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-light.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";

    cursor = {
      size = 32;
      package = pkgs.simp1e-cursors;
      name = "Simp1e-Catppuccin-Mocha";
    };

    icons = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      dark = "Flat-Remix-Grey-Dark";
      light = "Flat-Remix-Grey-Light";

    };

    opacity = {
      desktop = 0.95;
      terminal = 0.85;
    };


    fonts = {

        sansSerif = {
          package = pkgs.cantarell-fonts;
          name = "Figtree";
          # package = pkgs.dejavu_fonts;
          # name = "DejaVu Sans";
        };

        serif = config.stylix.fonts.sansSerif;

        monospace = {
          package = pkgs.nerd-fonts.sauce-code-pro;
          name = "SauceCodePro Nerd Font Mono";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "NotoColorEmoji";
        };

        sizes = {
          desktop = 12;
          applications = 12;
        };

      };

    # targets
    targets.firefox.profileNames = [ "default" ];
    targets.waybar.font = "sansSerif";
    targets.zellij.enable = true;

  };

  # services.wpaperd = {
  #     enable = true;
  #     package = pkgs.wpaperd.overrideAttrs (oldAttrs: rec {
  #         version = "1.3.0";
  #         name = "${oldAttrs.pname}-${version}";
  #
  #         src = pkgs.fetchFromGitHub {
  #         owner = "danyspin97";
  #         repo = "wpaperd";
  #         rev = "483225a9c6ad4f9bbf9104f958eafee9c47d4612";
  #         hash = "sha256-h9ksTGnAYg98TYguQXjjDkCO/EO2eeWZUJzOw7FuEF8=";
  #         }; 
  #
  #         cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
  #           inherit src;
  #           hash = "sha256-UeF5zSYXM3ERmaATKEHUMpOdhhI9FDqs4uRiDCNq38k=";
  #         };
  #
  #         });
  #
  #     settings = {
  #       default.path = "${config.home.homeDirectory}/Pictures/wallpapers";
  #
  #     };
  #
  #   };
  #
  services.awww.enable = true;

  systemd.user.services.awww-cycle-wallpaper =
  let 
  cycle-time = "300";
  cycle-awww-wallpaper = pkgs.writeScript "cycle-awww-wallpaper.sh" ''
  #!/usr/bin/env zsh
  while true; do
    for wallpaper in ${config.home.homeDirectory}/Pictures/wallpapers/*.{jpg,jpeg,png}; do
    ${(lib.getExe pkgs.awww)} img "$wallpaper"
    sleep ${cycle-time}
    done
  done
  ''; in
  {
    Unit = {
      Description = "awww-cycle-wallpaper";
      After="suspend.target";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart="${cycle-awww-wallpaper}";
      Type="simple";
      Restart="always";
      RestartSec=2;
    };
  };




    

}
