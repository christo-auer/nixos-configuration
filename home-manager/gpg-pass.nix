{ config, pkgs, private-values, ... } : {

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;
    enableSshSupport = true;
    sshKeys = [ private-values.ssh.key ];
  };

  home.packages = [ pkgs.gopass ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);


    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };


      
  };



}
