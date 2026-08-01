{ pkgs, lib, config, ...}:{

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "dialout" "networkmanager" "input" "docker" "lp" ]; 
    shell = pkgs.zsh;
  };

}
