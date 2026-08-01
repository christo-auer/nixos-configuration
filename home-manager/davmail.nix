{ pkgs, libs, config, ... }: {

  home.file.".config/davmail/davmail.properties".source = ./config/davmail/davmail.properties; 

  systemd.user.services.davmail = {
    Unit = {
      Description = "davmail";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart="${pkgs.davmail}/bin/davmail ${config.home.homeDirectory}/.config/davmail/davmail.properties";
      ExecStop="pkill -e \"java.*davmail\"";
      Type="simple";
      Restart="always";
      RestartSec=2;
    };
};






}
