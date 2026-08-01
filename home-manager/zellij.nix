{ pkgs, lib, config, ... }:{

  programs.zellij = {
    enable = true;

    enableZshIntegration = false;

    settings = {
      show_startup_tips = false;
      theme_dir = "${config.xdg.configHome}/zellij/themes";
      default_layout = "compact";
      default_mode = "locked";
      ui.pane_frames.hide_session_name = true;
      pane_frames = false;

      keybinds = let to_bind = key: action: {
          bind = {
            _args = key;
            _children = [
            action
            ];

            };
        }; in
      {
        normal._children = [
          (to_bind ["esc"] { SwitchToMode._args = ["locked"]; })
          (to_bind ["j"] { ScrollDown = []; })
          (to_bind ["k"] { ScrollUp = []; })
          (to_bind ["Ctrl f"] { HalfPageScrollDown = []; })
          (to_bind ["Ctrl b"] { HalfPageScrollUp = []; })
          (to_bind ["g" "g"] { ScrollToTop = []; })
          (to_bind ["G"] { ScrollToBottom = []; })
          (to_bind ["/"] { SwitchToMode._args = ["EnterSearch"]; SearchInput._args = [0]; })
          (to_bind ["n"] { Search._args = ["down"]; })
          (to_bind ["N"] { Search._args = ["up"]; })
          
        ];
        locked._children = [
          (to_bind ["Alt h"] { GoToPreviousTab = []; })
          (to_bind ["Alt l"] { GoToNextTab = []; })
          (to_bind ["Alt t"] { NewTab = []; })
          (to_bind ["Alt x"] { CloseTab = []; })
        ];
      };
    };


  };

}
