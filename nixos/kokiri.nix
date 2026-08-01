{ config, lib, pkgs, ... }:
{
  networking.hostName = "kokiri";
  #
  # hardware.graphics.extraPackages = with pkgs; [
  #   amdvlk
  # ];
  #
  hardware = {
  #tuxedo-rs = {
    #enable = true;
    # tailor-gui.enable = true;
  #};
    tuxedo-drivers.enable = true;
    tuxedo-control-center.enable = true;
  };

  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=0
  '';
}
