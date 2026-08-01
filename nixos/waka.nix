{ config, lib, pkgs, ... }:
{
  networking.hostName = "waka";

  boot.blacklistedKernelModules = [ "intel_ipu6" "intel_ipu6_isys" "intel_ipu6_psys" ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    intel-vaapi-driver # LIBVA_DRIVER_NAME=i965
    libvdpau-va-gl
  ];

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}
