{ lib, pkgs, config, stylix, ... }: {

  home.packages = [pkgs.trash-cli];

  programs.yazi =
  let open-and-hide = pkgs.writeShellScript "open-and-hide.sh" ''
  #!/usr/bin/env zsh

  mmsg dispatch toggle_scratchpad 1>/dev/null
  exec "$@"
  ''; in
  {
      enable = true;

      settings = {
          mgr.ratio = [0 1 1];

          opener = {
            xdg-open = [ { desc = "Default"; run = "${open-and-hide} xdg-open %s"; } ];
            libreoffice-draw = [ { desc = "LibreOffice Draw"; run = "${open-and-hide} libreoffice --draw %s"; } ];
            evince = [ { desc = "Evince"; run = "${open-and-hide} evince %s"; } ];
            send-to-remarkable = [ { desc = "Send to reMarkable"; run = "${config.xdg.configHome}/yazi/scripts/pdf2remarkable.sh %s"; block = true; } ];
            gimp = [ { desc = "Gimp"; run = "${open-and-hide} gimp %s"; } ];
            neovim = [ { desc = "nvim"; run = "$EDITOR %s"; block = true; } ];
            extract = [ { desc = "Extract here"; run = "ya pub extract --list %s"; } ];
          };

          open = {
              rules = [
                { url = "*.pdf"; use = ["xdg-open" "libreoffice-draw" "evince" "send-to-remarkable"]; }
                { mime = "image/*"; use = ["xdg-open" "gimp"]; }
                { url = "*"; use = ["xdg-open" "neovim" ]; }
                { url = "*.zip"; use = ["extract" ]; }
                { url = "*.tar.gz"; use = ["extract" ]; }
                { url = "*.tar.bz"; use = ["extract" ]; }
                { url = "*.tar.xz"; use = ["extract" ]; }
                { url = "*.rar"; use = ["extract" ]; }
                { url = "*.7z"; use = ["extract" ]; }
              ];
            };
      };

      theme.indicator.current.reversed = true;

      keymap = {
        mgr.prepend_keymap = [
          { on = ["g" "d"]; run = "cd ~/Downloads"; }
          { on = ["g" "h"]; run = "cd ~"; }
          { on = ["g" "D"]; run = "cd ~/Documents"; }
          { on = ["g" "w"]; run = "cd ~/Documents/workspace"; }
          { on = ["g" "W"]; run = "cd ~/Documents/work"; }
          { on = ["g" "t"]; run = "cd ~/temp"; }
          { on = ["g" "r"]; run = "cd ~/remote"; }
          { on = ["g" "t"]; run = "cd ~/remote"; }
          { on = ["g" "m"]; run = "plugin mount"; }
          { on = ["<enter>"]; run = "plugin smart-enter"; }
          { on = ["l"]; run = "plugin smart-enter"; }
          { on = ["p"]; run = "plugin smart-paste"; }
          { on = ["d"]; run = "remove --force"; }
          { on = ["u"]; run = "plugin restore"; }
          { on = ["U"]; run = "plugin restore --interactive --interactive-overwrite"; }
          { on = ["z" "l"]; run = "plugin time-travel next"; }
          { on = ["z" "h"]; run = "plugin time-travel prev"; }
          { on = ["z" "e"]; run = "plugin time-travel exit"; }
          { on = ["<C-j>"]; run = "plugin nav-parent-panel next"; }
          { on = ["<C-k>"]; run = "plugin nav-parent-panel prev"; }


        ];
      };

      plugins = with pkgs.yaziPlugins; {
        mount = mount;
        smart-enter = smart-enter;
        smart-paste = smart-paste;
        # recycle-bin = recycle-bin;
        restore = restore;
        time-travel = time-travel;
        nav-parent-panel = nav-parent-panel;
      };

      shellWrapperName = "y";

  };


}
