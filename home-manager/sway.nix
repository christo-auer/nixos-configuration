{ config, pkgs, lib, ... } : {

  programs.swaylock.enable = true;
  services.mako = {
    enable = true;
    settings.defaultTimeout = 5000;
  };

  services.swaync = {
      enable = true;
  };

  services.way-displays.enable = true;

  wayland.windowManager.sway = 
  with builtins;
  with lib.attrsets;
  {

    package = pkgs.swayfx;
    checkConfig = false;

    enable = true;

    wrapperFeatures.gtk = true;

    config = 
    let 
      ws-for-name = { mail = "3"; browser = "2"; news = "4"; };
      wsForKey = { "y"="0"; "u"="1"; "i"="2"; "o"="3"; "p"="4"; "8"="6"; "9"="7"; };
      dirForKey = { "h" = "left"; "l" = "right"; "k" = "up"; "j" = "down"; };
      mod = "Mod4";
      alt = "Mod1";
      bell-sound = "/var/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga";
      fuzzel = "${pkgs.fuzzel}/bin/fuzzel";
      terminal = "foot";
      browser = "firefox";
      claude-command = "claude-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland";
      sane-center = {
        size-percent = "80";
        command = "resize set ${sane-center.size-percent} ppt ${sane-center.size-percent} ppt, move position center";
      };
      default-apps = [
        { start-key="Shift+n"; toggle-key ="n"; auto-start    =true; scratch =false; title = "neomutt" ;         command = "--working-directory ~/Downloads -e neomutt"; }
        { start-key="Shift+7"; toggle-key ="7";  auto-start   =true; scratch =true;  title = "spotify-player";   command = "-e spotify_player"                         ; }         
        { start-key="Shift+z"; toggle-key ="";  auto-start    =true; scratch =false; title = "eilmeldung TUI";         command = "-e eilmeldung"                               ; }         
        { start-key="Shift+f"; toggle-key ="f"; auto-start    =true; scratch =true;  title = "yazi scratch"    ; command = "-e yazi"                                   ; }
        { start-key="question"; toggle-key="slash"; auto-start=true; scratch =true;  title = "terminal scratch"; command = "-e zellij"                                    ; }
        { start-key="Shift+x"; toggle-key ="x"; auto-start    =false; scratch=true;  title = "gotop scratch"  ;  command = "-e gotop"                                  ; }
      ];
      scratch-apps = filter (builtins.getAttr "scratch") default-apps;
      startup-apps = filter (builtins.getAttr "auto-start") default-apps;
      ws-assignments = with ws-for-name; [
        { regex = ".*Firefox.*$";  ws = ws-for-name.browser; }
        { regex = "^neomutt$";   ws = mail; }
        { regex = "^eilmeldung TUI.*$"; ws = news; }
      ];
      startup-commands = [
        "${browser} --new-instance"
        # "way-displays"
        claude-command
        "tuxedo-control-center --tray"
      ];
      modes = {
        fuzzel =  "mode: (c)onnections (b)luetooth (s)ound (p)ass" ;
        session = "mode: (l)ock l(o)gout (s)uspend (r)eboot (S)hutdown";
        resize =  "mode: resize" ;
        presentation = "mode: presentation (m)irror (k)ill set-(o)utput set-(r)egion unset-(R)egion set-(s)aling toggle-(f)reeze (c)ustom";
      };

      resize = { px = "100"; ppt = "10"; };
      mk-binds = targetForKey: mods: command: mapAttrs'
         (key: target: 
           { 
             name = "${mods}+${key}"; 
             value = (builtins.replaceStrings ["%"] ["${target}"] "${command}") ; 
            }) targetForKey;
      mk-binds-for-dirs = mk-binds dirForKey;
      mk-binds-for-ws = mk-binds wsForKey;
      to-scratchpad-toggle =  {title, toggle-key, ...}: { name="${mod}+${toggle-key}"; value = "[app_id=\"^${title}\$\"] scratchpad show"; };
      to-start-bind =  {title, start-key, command, ...}: { name="${mod}+${start-key}"; value = "exec ${terminal} --app-id \"${title}\" --title \"${title}\" ${command}"; };
      to-startup-command =  {title, command, ...}: { command = "exec ${terminal} --app-id \"${title}\" --title \"${title}\" ${command}"; always = false;  };
    in
    {
      terminal = terminal;
      # modifier = mod;
      
      keybindings 
      = 
        # window/workspace mgmt
        mk-binds-for-dirs "${mod}" "focus %"
        // mk-binds-for-dirs "${mod}+Shift" "move %"
        // mk-binds-for-ws "${mod}" "workspace %"
        // mk-binds-for-ws "${mod}+Shift" "move container to workspace number %"
        // mk-binds-for-ws "${mod}+${alt}" "move container to workspace number %; workspace number %"
        // mk-binds-for-dirs "${mod}+${alt}" "move workspace to output %"
        // listToAttrs (map to-scratchpad-toggle scratch-apps)
        // listToAttrs (map to-start-bind default-apps)
        //
        { 
          "${mod}+s"              = "scratchpad show"; 
          "${mod}+minus"          = "split vertical";
          "${mod}+bar"            = "split horizontal";
          "${mod}+semicolon"      = "fullscreen toggle";
          "${mod}+Ctrl+semicolon" = "floating toggle";
          "${mod}+${alt}+s"       = "sticky toggle";
          "${mod}+Shift+s"        = "move to scratchpad";
          "${mod}+t"              = "layout toggle tabbed splitv splith";
          "${mod}+Shift+t"        = "layout toggle split";
          "${mod}+comma"          = "[title=\"^Claude\$\"] scratchpad show";
          "${mod}+1"              = "exec play ${./config/sway/airhorn.ogg}";
          "${mod}+2"              = "exec play ${./config/sway/eagle.ogg}";
          "${mod}+3"              = "exec play ${./config/sway/klausurrelevant.ogg}";

        } 
        //
        { # launcher
          "${mod}+Return"       = "exec ${terminal}";
          "${mod}+Shift+Return" = "exec ${browser}";
          "${mod}+space"        = "exec ${fuzzel}";
          "${mod}+Shift+space"  = "exec ${fuzzel} --list-executables-in-path";
          "${mod}+less"         = "exec ${claude-command}";
        }
        // # modes 
        {
          "${mod}+n" = "mode \"${modes.fuzzel}\"";
          "${mod}+r" = "mode \"${modes.resize}\"";
          "${mod}+b" = "mode \"${modes.session}\"";
          "${mod}+q" = "mode \"${modes.presentation}\"";
        }
        // 
        { # session/process mgmt
          "${mod}+m"       = "[con_id=\"__focused__\"] kill";
          "${mod}+Shift+m" = "[con_id=\"__focused__\"] exec --no-startup-id kill -9 $(xdotool getwindowfocus getwindowpid)";
          "${mod}+Ctrl+r"  = "reload";
        }
        //
        { # sane resize for floating window
          "${mod}+period" = "${sane-center.command}";
        }
        // # fn-keys
        {
          # brightness
          "XF86MonBrightnessUp"          = "exec brightnessctl set +10%";
          "XF86MonBrightnessDown"        = "exec brightnessctl set 10%-";
          "${mod}+XF86MonBrightnessUp"   = "exec brightnessctl set +1%";
          "${mod}+XF86MonBrightnessDown" = "exec brightnessctl set 1%-";
#  # volume
          "XF86AudioRaiseVolume"       = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%; exec play ${bell-sound}";
          "XF86AudioLowerVolume"       = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%; exec play ${bell-sound}";
          "XF86AudioMute"              = "exec --no-startup-id pactl -- set-sink-mute @DEFAULT_SINK@ toggle # mute sound; exec play ${bell-sound}";
        #  # music control
          "XF86AudioPlay"              = "exec playerctl play-pause";
          "XF86AudioPause"             = "exec playerctl play-pause";
          "XF86AudioNext"              = "exec playerctl next";
          "XF86AudioPrev"              = "exec playerctl previous";
          "${mod}+bracketright"          = "exec playerctl next";
          "${mod}+bracketleft"           = "exec playerctl previous";
          "${mod}+equal"                 = "exec playerctl play-pause";
        }
        ;

        floating = {
          modifier = mod;
          border = 2;
        };

        startup = 
          map to-startup-command startup-apps
          ++
          map 
            (startup-command: 
              { command = startup-command; always = false;  }) 
            startup-commands
        ;

        window = {
          hideEdgeBorders = "smart";
          border = 2;

          commands = 
          let to-scratch-command = 
            {title, ...}:
            {
              criteria.app_id = "^${title}\$";
              command        = "floating enable, " + sane-center.command + ", move scratchpad";
            };
            to-move-to-ws-command = 
            { regex, ws }: { 
              criteria.title = regex; 
              command = "move to workspace ${ws}";
            };
          in 
          (map to-scratch-command scratch-apps) 
          ++
          (map to-move-to-ws-command ws-assignments)
          ++ 
          [
            { criteria.title = "^Picture-in-Picture"; command = "floating enable, sticky enable"; }
            { criteria.title = "^feh"; command = "floating enable"; }
            { criteria.class = "zoom"; command = "floating enable"; }  
            { criteria.title = "^Claude\$"; command = "floating enable, " + sane-center.command + ", move scratchpad"; }  
          ]
          ;

        };

        modes =
        {
          "${modes.fuzzel}" = 
          let fuzzel-dir = "~/.config/fuzzel";
              choosers = "${fuzzel-dir}/choose";
              
          in
          {
            c      = "exec --no-startup-id ${fuzzel-dir}/fuzzel-buerste.sh ${fuzzel} ${choosers}-nm-connection.sh; mode default";
            b      = "exec --no-startup-id ${fuzzel-dir}/fuzzel-buerste.sh ${fuzzel} ${choosers}-bluetooth.sh; mode default";
            s      = "exec --no-startup-id ${fuzzel-dir}/fuzzel-buerste.sh ${fuzzel} ${choosers}-pipewire-sink.sh; mode default";
            p      = "exec --no-startup-id ${fuzzel-dir}/fuzzel-buerste.sh ${fuzzel} ${choosers}-pass.sh; mode default";
            o      = "exec --no-startup-id ${fuzzel-dir}/fuzzel-buerste.sh ${fuzzel} ${choosers}-otp.sh; mode default";
            Escape = "mode \"default\"";
            };
          "${modes.resize}" = {
            "h"       = "resize shrink width ${resize.px} px or ${resize.ppt} ppt";
            "l"       = "resize grow width ${resize.px} px or ${resize.ppt} ppt";
            "k"       = "resize shrink height ${resize.px} px or ${resize.ppt} ppt";
            "j"       = "resize grow height ${resize.px} px or ${resize.ppt} ppt";
            "${mod}+h"  = "move left ${resize.px} px";
            "${mod}+j"  = "move down ${resize.px} px";
            "${mod}+k"  = "move up ${resize.px} px";
            "${mod}+l"  = "move right ${resize.px} px";
            "3"       = "resize set width 30 ppt";
            "4"       = "resize set width 40 ppt";
            "5"       = "resize set width 50 ppt";
            "6"       = "resize set width 60 ppt";
            "Shift+3" = "resize set height 30 ppt";
            "Shift+4" = "resize set height 40 ppt";
            "Shift+5" = "resize set height 50 ppt";
            "Shift+6" = "resize set height 60 ppt";
            "Escape"  = "mode \"default\"";
          };
          "${modes.session}" = {
            "l"       = "exec --no-startup-id swaylock, mode \"default\"";
            "o"       = "exec --no-startup-id sway exit";
            "s"       = "exec --no-startup-id systemctl suspend, mode \"default\"";
            "r"       = "exec --no-startup-id systemctl reboot, mode \"default\"";
            "Shift+s" = "exec --no-startup-id systemctl poweroff, mode \"default\"";
            "Escape"  = "mode \"default\"";
          };
          "${modes.presentation}" = {
            "m"        = "mode \"default\"; exec wl-present mirror";
            "k"        = "mode \"default\"; exec pkill wl-mirror";
            "o"        = "mode \"default\"; exec wl-present set-output";
            "r"        = "mode \"default\"; exec wl-present set-region";
            "Shift+r"  = "mode \"default\"; exec wl-present unset-region";
            "s"        = "mode \"default\"; exec wl-present set-scaling";
            "f"        = "mode \"default\"; exec wl-present toggle-freeze";
            "c"        = "mode \"default\"; exec wl-present custom";
            "Return"   = "mode \"default\"";
            "Escape"   = "mode \"default\"";
          };

        };

      gaps = {
          inner = 2;
          outer = 2;
          smartGaps = true;
      };

      bars = [
      {
        command = "waybar";
        position = "bottom";
        hiddenState = "hide";
        mode = "hide";
# modifier = "${mod}";
      }


      ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "altgr-intl";
        };

       "type:touchpad" = {
         tap               = "enabled";
         drag              = "enabled";
         drag_lock         = "enabled";
         tap_button_map    = "lrm";
         dwt               = "enabled";
         dwtp              = "enabled";
         natural_scroll    = "enabled";
       };

      };

    };

    extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
      export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
    '';


    extraConfig = ''
      popup_during_fullscreen smart
      floating_minimum_size 500 x 300
      floating_maximum_size 2000 x 1500
      default_border pixel 1
      default_floating_border pixel 1

      # swayfx eye candy
      blur enable
      blur_passes 3
      blur_radius 5
      shadows enable
      shadow_blur_radius 3 
      corner_radius 12
      default_dim_inactive 0.05
      layer_effects "waybar" {
        shadows disable
        blur disable
      }
    '';

  };

}

