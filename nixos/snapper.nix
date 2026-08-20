{ ... }:{
  systemd.services.snapper.enable = true;

  services.snapper = {

    configs = {
      home = {
        TIMELINE_CREATE=true;
        TIMELINE_CLEANUP=true;
        SUBVOLUME="/home";
      	ALLOW_USERS=["chris"];
      };

    };

  };

}

