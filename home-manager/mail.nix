{ config, pkgs, lib, ... } : {

  # programs.meli.enable = true;

  imports = [
    ./mail-haw.nix
    ./mail-private.nix
  ];

  accounts.email.maildirBasePath = ".mail";

}

