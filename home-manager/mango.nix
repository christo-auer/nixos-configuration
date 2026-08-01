{ config, private-data, pkgs, lib, ... }:
let
  mod            = "SUPER";
  terminal       = "foot";
  browser        = "firefox";
  fuzzel         = "${pkgs.fuzzel}/bin/fuzzel";
  claude-command = "claude-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland";
  bell-sound     = "/var/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga";

  wsForKey    = { "y" = "1"; "u" = "2"; "i" = "3"; "o" = "4"; "p" = "5"; "8" = "7"; "9" = "8"; };
  ws-for-name = { mail = "4"; browser = "3"; news = "5"; };
  dirForKey   = { "h" = "left"; "l" = "right"; "k" = "up"; "j" = "down"; };

  scratch-size = { w = "0.8"; h = "0.8"; };

  default-apps = [
    { start-key = "Shift+n"; toggle-key = "n";     auto-start = true;  scratch = false; title = "neomutt";          command = "--working-directory ~/Downloads -e neomutt"; }
    { start-key = "Shift+7"; toggle-key = "7";     auto-start = true;  scratch = true;  title = "spotify-player";   command = "-e spotify_player"; }
    { start-key = "Shift+z"; toggle-key = "";      auto-start = true;  scratch = false; title = "eilmeldung TUI";    command = "-e eilmeldung"; }
    { start-key = "Shift+f"; toggle-key = "f";     auto-start = true;  scratch = true;  title = "yazi scratch";     command = "-e yazi"; }
    { start-key = "question"; toggle-key = "slash"; auto-start = true; scratch = true;  title = "terminal scratch"; command = "-e zellij"; }
    { start-key = "Shift+x"; toggle-key = "x";     auto-start = false; scratch = true;  title = "gotop scratch";    command = "-e gotop"; }
  ];

  scratch-apps = builtins.filter (a: a.scratch) default-apps;
  autostart-apps = builtins.filter (a: a.auto-start && !a.scratch) default-apps;

  startup-commands = [
    "${browser} --new-instance"
    "tuxedo-control-center --tray"
  ];

  ws-assignments = [
    { regex = ".*Firefox.*$";       ws = ws-for-name.browser; }
    { regex = "^neomutt$";          ws = ws-for-name.mail; }
    { regex = "^eilmeldung TUI.*$"; ws = ws-for-name.news; }
  ];

  mapMod = m: {
    "Shift" = "SHIFT";
    "Ctrl"  = "CTRL";
    "Mod1"  = "ALT";
  }.${m} or m;

  toMango = combo:
    let
      parts   = lib.splitString "+" combo;
      key     = lib.last parts;
      rawMods = lib.init parts;
      mods    = [ mod ] ++ (map mapMod rawMods);
    in "${lib.concatStringsSep "+" mods},${key}";

  spawnTerm = a: "${terminal} --app-id \"${a.title}\" --title \"${a.title}\" ${a.command}";

  focus-binds  = lib.mapAttrsToList (k: d: "${mod},${k},focusdir,${d}") dirForKey;
  move-binds   = lib.mapAttrsToList (k: d: "${mod}+SHIFT,${k},exchange_client,${d}") dirForKey;
  ws-view      = lib.mapAttrsToList (k: t: "${mod},${k},view,${t},0") wsForKey;
  ws-move      = lib.mapAttrsToList (k: t: "${mod}+SHIFT,${k},tagsilent,${t}") wsForKey;
  ws-move-view = lib.mapAttrsToList (k: t: "${mod}+ALT,${k},tag,${t},0") wsForKey;

  start-binds  = map (a: "${toMango a.start-key},spawn_shell,${spawnTerm a}") default-apps;
  toggle-binds = map (a: "${mod},${a.toggle-key},toggle_named_scratchpad,${a.title},none,${spawnTerm a}") scratch-apps;

  scratch-rules = map
    (a: "isnamedscratchpad:1,isfloating:1,width:${scratch-size.w},height:${scratch-size.h},appid:${a.title}")
    scratch-apps;
  ws-rules = map (r: "tags:${r.ws},title:${r.regex}") ws-assignments;

  static-binds = [
    # window / session mgmt
    "${mod},s,toggle_scratchpad"
    "${mod}+SHIFT,s,minimized"
    "${mod},semicolon,togglefullscreen"
    "${mod}+CTRL,semicolon,togglefloating"
    "${mod}+ALT,s,toggleglobal"
    "${mod},period,spawn_shell,${resize-and-center}"
    "${mod},m,killclient"
    "${mod}+SHIFT,m,spawn_shell,kill -9 $(xdotool getwindowfocus getwindowpid)"
    "${mod}+CTRL,r,reload_config"
    "${mod},comma,toggle_named_scratchpad,none,Claude,${claude-command}"
    "${mod},1,setlayout,tile"
    "${mod},2,setlayout,monocle"
    "${mod},3,setlayout,deck"
    "${mod},g,setlayout,overview"
    "${mod},bracketright,focusstack,next"
    "${mod},bracketleft,focusstack,prev"
    "${mod}+Shift,bracketright,exchange_stack_client,next"
    "${mod}+Shift,bracketleft,exchange_stack_client,prev"


    # sound bites
    "${mod},4,spawn,play ${private-data}/media/eagle.ogg"
    "${mod},5,spawn,play ${private-data}/media/airhorn.ogg"
    "${mod},6,spawn,play ${private-data}/media/klausurrelevant.ogg}"
    # launchers
    "${mod},Return,spawn,${terminal}"
    "${mod}+SHIFT,Return,spawn,${browser}"
    "${mod},space,spawn,${fuzzel}"
    "${mod}+SHIFT,space,spawn,${fuzzel} --list-executables-in-path"
    "${mod},less,spawn_shell,${claude-command}"
    # enter modes
    "${mod},n,setkeymode,menu"
    "${mod},b,setkeymode,session"
    "${mod},q,setkeymode,presentation"
    "${mod},r,setkeymode,resize"
    # fn / media keys
    "NONE,XF86MonBrightnessUp,spawn,brightnessctl set +10%"
    "NONE,XF86MonBrightnessDown,spawn,brightnessctl set 10%-"
    "${mod},XF86MonBrightnessUp,spawn,brightnessctl set +1%"
    "${mod},XF86MonBrightnessDown,spawn,brightnessctl set 1%-"
    "NONE,XF86AudioRaiseVolume,spawn_shell,pactl set-sink-volume @DEFAULT_SINK@ +5% ; play ${bell-sound}"
    "NONE,XF86AudioLowerVolume,spawn_shell,pactl set-sink-volume @DEFAULT_SINK@ -5% ; play ${bell-sound}"
    "NONE,XF86AudioMute,spawn_shell,pactl -- set-sink-mute @DEFAULT_SINK@ toggle ; play ${bell-sound}"
    "NONE,XF86AudioPlay,spawn,playerctl play-pause"
    "NONE,XF86AudioPause,spawn,playerctl play-pause"
    "NONE,XF86AudioNext,spawn,playerctl next"
    "NONE,XF86AudioPrev,spawn,playerctl previous"
    "${mod},bracketright,spawn,playerctl next"
    "${mod},bracketleft,spawn,playerctl previous"
    "${mod},equal,spawn,playerctl play-pause"
  ];

  all-binds =
    focus-binds ++ move-binds ++ ws-view ++ ws-move ++ ws-move-view
    ++ start-binds ++ toggle-binds ++ static-binds;

  fuzzel-dir = "~/.config/fuzzel";
  chooser    = "${fuzzel-dir}/choose";
  buerste    = "${fuzzel-dir}/fuzzel-buerste.sh";

  spawn-and-reset-keymode = pkgs.writeScript "spawn-and-reset-keymode.sh" ''
    #!/usr/bin/env sh
    mmsg dispatch "setkeymode,default"
    eval $@
  '';

  resize-and-center = pkgs.writeScript "resize-and-center.sh" ''
    #! /usr/bin/env nix-shell
    #! nix-shell -i zsh -p jq

    monitor=$(mmsg get last_open_surface | jq -r .monitor)

    width=$(mmsg get monitor "$monitor" | jq .width)
    height=$(mmsg get monitor "$monitor" | jq .height)

    new_width=$(((3 * $width) / 4))
    new_height=$(((3 * $height) / 4))

    mmsg dispatch "resizewin,$new_width,$new_height"
    mmsg dispatch "centerwin"
  '';
 

  modeRun = key: cmd: [
    "NONE,${key},spawn,${spawn-and-reset-keymode} ${cmd}"
  ];
in
{
  programs.swaylock.enable = true;
  services.mako = {
    enable = true;
    settings.defaultTimeout = 5000;
  };
  services.swaync.enable = true;
  services.way-displays.enable = true;

  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    settings = {
      # ---- keybindings ----
      bind = all-binds;

      # floating window mouse move/resize (SUPER + drag)
      mousebind = [
        "${mod},btn_left,moveresize,curmove"
        "${mod},btn_right,moveresize,curresize"
      ];

      # ---- modes ----
      keymode = {
        resize.bind = [
          "NONE,h,resizewin,-100,0"
          "NONE,l,resizewin,+100,0"
          "NONE,j,resizewin,0,-100"
          "NONE,k,resizewin,0,+100"
          "NONE,Return,setkeymode,default"
          "NONE,Escape,setkeymode,default"
        ];
        menu.bind =
          (modeRun "c" "${buerste} ${fuzzel} ${chooser}-nm-connection.sh")
          ++ (modeRun "b" "${buerste} ${fuzzel} ${chooser}-bluetooth.sh")
          ++ (modeRun "s" "${buerste} ${fuzzel} ${chooser}-pipewire-sink.sh")
          ++ (modeRun "p" "${buerste} ${fuzzel} ${chooser}-pass.sh")
          ++ (modeRun "o" "${buerste} ${fuzzel} ${chooser}-otp.sh")
          ++ [
            "NONE,Return,setkeymode,default"
            "NONE,Escape,setkeymode,default"
          ];

        session.bind = 
          (modeRun "l" "swaylock")
          ++ (modeRun "o" "quit")
          ++ (modeRun "s" "systemctl suspend")
          ++ (modeRun "r" "systemctl reboot")
          ++ (modeRun "d" "systemctl poweroff")
          ++ [
            "NONE,Return,setkeymode,default"
            "NONE,Escape,setkeymode,default"
          ];

        presentation.bind =
          (modeRun "m" "wl-present mirror")
          ++ (modeRun "k" "pkill wl-mirror")
          ++ (modeRun "o" "wl-present set-output")
          ++ (modeRun "r" "wl-present set-region")
          ++ (modeRun "u" "wl-present unset-region")
          ++ (modeRun "s" "wl-present set-scaling")
          ++ (modeRun "f" "wl-present toggle-freeze")
          ++ (modeRun "c" "wl-present custom")
          ++ [
            "NONE,Return,setkeymode,default"
            "NONE,Escape,setkeymode,default"
          ];
      };

      windowrule = scratch-rules ++ ws-rules ++ [
        "isnamedscratchpad:1,isfloating:1,width:${scratch-size.w},height:${scratch-size.h},title:Claude"
        "isfloating:1,isglobal:1,title:^Picture-in-Picture"
        "isfloating:1,title:^feh"
        "isfloating:1,appid:zoom"
      ];

      tagrule = map (i: "id:${toString i},layout_name:tile") (lib.range 1 9);

      layerrule = [
        "noshadow:1,layer_name:waybar"
      ];

      xkb_rules_layout  = "us";
      xkb_rules_variant = "altgr-intl";
      tap_to_click              = 1;
      tap_and_drag              = 1;
      drag_lock                 = 1;
      button_map                = 0;
      trackpad_natural_scrolling = 1;
      disable_while_typing      = 1;

      # ---- appearance / gaps (community defaults) ----
      gappih  = 2;
      gappiv  = 2;
      gappoh  = 2;
      gappov  = 2;
      smartgaps = 2;
      borderpx  = 1;
      scratchpad_width_ratio  = 0.8;
      scratchpad_height_ratio = 0.9;

      rootcolor           = "0x${config.lib.stylix.colors.base00}ff";
      bordercolor         = "0x${config.lib.stylix.colors.base03}ff";
      focuscolor          = "0x${config.lib.stylix.colors.base0D}ff";
      dropcolor           = "0x${config.lib.stylix.colors.base0B}55";
      splitcolor          = "0x${config.lib.stylix.colors.base09}ff";
      maximizescreencolor = "0x${config.lib.stylix.colors.base0A}ff";
      urgentcolor         = "0x${config.lib.stylix.colors.base08}ff";
      scratchpadcolor     = "0x${config.lib.stylix.colors.base0F}ff";
      globalcolor         = "0x${config.lib.stylix.colors.base0E}ff";
      overlaycolor        = "0x${config.lib.stylix.colors.base0C}ff";

      blur                    = 1;
      blur_layer              = 1;
      blur_optimized          = 1;
      blur_params_num_passes  = 2;
      blur_params_radius      = 5;
      shadows            = 1;
      layer_shadows      = 1;
      shadow_only_floating = 1;
      shadows_size       = 8;
      shadows_blur       = 15;
      shadowscolor       = "0x000000ee";
      border_radius      = 6;
      no_radius_when_single = 0;

      animations                = 1;
      layer_animations          = 1;

      cursor_hide_timeout = 5;
      scratchpad_cross_monitor = 1;
      focus_on_activate = 0;
      no_border_when_single = 1;

    };

    autostart_sh = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
      export GNOME_KEYRING_CONTROL="/run/user/$UID/keyring"
    ''
    + lib.concatMapStrings (a: "${spawnTerm a} &\n") autostart-apps
    + lib.concatMapStrings (c: "${c} &\n") startup-commands;
  };
}
