
{  pkgs, private-values, ... } : {

  programs.waybar = 
  let 
  mail-config = private-values.mail;
  mail-indicator = pkgs.writeScript "mail-indicator.sh" ''
    #!/usr/bin/env zsh

    function query_unread() {
      curl -u $1:$2 -n imaps://$3 -X 'STATUS INBOX (UNSEEN)' --silent | tail -n 1 
    }

    private=$(query_unread ${mail-config.private.config.userName} $(pass private/mail | head -n1) ${mail-config.private.config.imap.host} | grep 'STATUS INBOX' | sed -e 's/\* STATUS INBOX (UNSEEN \(.*\))/\1/; s/\r//g')

    haw=$(query_unread ${mail-config.haw.config.userName} $(pass haw/mail | head -n1) ${mail-config.haw.config.imap.host} | grep 'STATUS INBOX' | sed -e 's/\* STATUS INBOX (UNSEEN \([0-9]\+\)\w*)/\1/; s/\r//g; s/ //g')

    [ "''${private}" = "0" -a "''${haw}" = "0" ] && exit 0

    echo "''${private:--}/''${haw:--}"
  ''; in

  {

    package = (pkgs.waybar.override { cavaSupport = false; }).overrideAttrs (oldAttrs: {
        pname = "waybar";
        version = "git";
        src = pkgs.fetchFromGitHub {
        owner = "Alexays";
        repo = "Waybar";
        rev = "d44a27af1023b5c68f6f61435ba550bf03f69938";  
        hash = "sha256-qquPn4ibBnc7gA4peGgseP+lKGRq58UPxsMTSrdUT8Q=";
        };
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dmango=true" "-Dwwan=disabled" ];
        doInstallCheck = false;
        });

    enable = true;

    settings = 
    let workspace-icons = {
            "1"="󰎣";
            "2"="󰎦";
            "3"="󰈹";
            "4"="";
            "5"="";
            "6"="󰎩";
            "7"="󰎬";
            "8"="󰎮";
            "9"="";
      };
    in
    {
      main = {

        reload_on_style_change = "true";
        layer = "bottom";
        position = "bottom";
        # height = 26;
        spacing = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        ipc = true;
        modules-left = [ "mango/workspaces" "mango/window" "mango/keymode" ];
        modules-right = [ "custom/mail" "battery" "cpu" "tray" "clock" ];

        "clock" = {
          format = "{:%d. %h %H:%M}";
        };

        "mango/workspaces" = {
          format = "{icon}";
          format-icons = workspace-icons;
          hide-empty = true;
          on-click = "activate";
          on-click-right = "toggle";
        };

        "mango/keymode" = {
          format = "{}";
          format-default = "";
          format-presentation = "(m)irror (k)ill (o)utput (r)egion (u)nset (s)caling (f)reeze (c)ustom";
          format-session = "(l)ock (s)uspend (r)eboot l(o)gout shut(d)own";
          format-menu = "(c)onnections (b)luetooth (s)ound (p)ass (o)tp";
        };

        battery = {
          interval = 15;
          format = "{icon}{capacity:5}%";
          format-icons = ["" "" "" "" ""];
        };

        cpu = {
          format = "{usage:2}%";
        };

        "custom/mail" = {
          format = " {}";
          interval = 60;
          exec = "${mail-indicator}";
        };

      };


    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        margin: 0;
        padding: 0;
        font-family: "Figtree Light", monospace;
        font-size: 18px;
      }

      /* glassy flat bar: semi-transparent so mango layer blur shows through */
      window#waybar {
        background: alpha(@base00, 0.8);
        color: @base05;
      }

      /* ---- workspaces: flat, accent text + thin underline ---- */
      #workspaces button {
        padding: 0 8px;
        color: @base05;
      }


      #workspaces button.current_output {    /* currently viewed */
        color: @base0D;
      }

      #workspaces button.urgent,
      #workspaces button.overview {
        color: @base08;
      }

      #workspaces button.active {    /* currently viewed */
        color: @base0D;
      }

      #workspaces button.empty {
        color: @base03;
      }

      /* ---- keymode: subtle accent chip (rare/transient) ---- */
      #keymode {
        color: @base00;
        background: @base0D;
        padding: 0 8px;
        margin: 3px 0 3px 6px;
        border-radius: 4px;
      }

      /* ---- right cluster: one shared flat strip, thin separators ---- */
      #custom-mail,
      #battery,
      #cpu,
      #tray,
      #clock {
        color: @base05;
        padding: 0 10px;
        border-right: 1px solid alpha(@base04, 0.3);
      }

      /* last item: drop the trailing separator */
      #clock {
        border-right: none;
        font-weight: bold;
      }

      #tray {
        padding: 0 6px;
      }

      #battery.warning {
        color: @base09;
      }

      #battery.critical {
        color: @base08;
      }
    '';



    systemd = {
      enable = true;
      targets = ["mango-session.target"];

    };



  };

}
