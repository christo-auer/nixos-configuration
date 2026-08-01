{ config, lib, pkgs, ... }:{
  systemd.services.snapper.enable = true;

  services.snapper = {

    configs = let
      common = {
        TIMELINE_CREATE=true;
        TIMELINE_CLEANUP=true;
      };
    in
    {
      home = common // {
        SUBVOLUME="/home";
      	ALLOW_USERS=["chris"];
      };
      root = common // {
        SUBVOLUME="/";
      };

    };

  };

}

