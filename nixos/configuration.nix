{ config, lib, pkgs, ... }:
      let
      openjdk-overlay = (
        final: prev: {
          jdk8 = final.openjdk8-bootstrap;
        }

      );
      in
{

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ openjdk-overlay ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  networking.firewall = {
          
          checkReversePath = false;
          allowedTCPPorts = [ 53317 ]; # localsend
  };

  # virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "chris" ];
  # virtualisation.virtualbox.host.enableHardening = false;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  
  services.flatpak.enable = true;
  services.fwupd.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };


  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      # package = pkgs.bluez;

      settings.General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    graphics = {
      enable = true;
    };
  };

  

  services = {
    printing = {
        enable = true;
        drivers = with pkgs; [ hplip ];
    };
    blueman.enable = true;
    openssh.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };

      wireplumber = {
        enable =  true;
        # extraConfig.bluetoothEnhancements = {
        #   "monitor.bluez.properties" = {
        #     "bluez5.enable-sbc-xq" = true;
        #     "bluez5.enable-msbc" = true;
        #     "bluez5.enable-hw-volume" = true;
        #     "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        #   };
        # };
      };
    };
    dbus.packages = [ pkgs.gcr ];
    tlp.enable = true;
    udisks2.enable = true;
    gnome.gnome-keyring.enable = true;


  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services = {
    swaylock.text = "auth include login";
    login.enableGnomeKeyring = true;
  };

  security.sudo.wheelNeedsPassword = false;

  programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
  };


  environment.systemPackages = with pkgs; [
    # bluez
    # bluez-tools
    dconf
    flatpak
    git
    gnome-software
    gnome-keyring
    lsof
    nfs-utils
    nh
    niri
    networkmanagerapplet
    networkmanager-fortisslvpn
    networkmanager-openconnect
    openfortivpn
    wireguard-tools
    pulseaudio
    snapper
    udevil
    wget
  ];

  programs = {
    zsh.enable = true;
    wshowkeys.enable = true;
  };


  system.stateVersion = "24.11"; 

}

