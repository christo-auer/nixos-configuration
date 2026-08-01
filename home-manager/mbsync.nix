{ config, pkgs, lib, ... } : {

  programs.mbsync = {
      enable = true;
  };

  services.mbsync = {
    enable = true;
    frequency = "*:0/15";
    postExec = "notmuch new";
  };


}


