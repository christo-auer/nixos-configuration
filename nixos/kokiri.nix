{ config, lib, pkgs, ... }:
{
  networking.hostName = "kokiri";

  boot.kernelParams = ["pcie_aspm=off"];

  hardware = {
    tuxedo-drivers.enable = true;
    tuxedo-control-center.enable = true;
  };

  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=0
    options iwlwifi power_save=1
  '';
}
