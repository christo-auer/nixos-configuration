{ ... }: {
  services.keyd = {
    enable = true;

    keyboards = 
    let default-settings = 
        {
          main = {
            capslock = "escape";
            tab = "overload(nav, tab)";
          };

          nav = {
            j = "down";
            k = "up";
            h = "left";
            l = "right";
            space = "backspace";
            n = "home";
            m = "end";
            u = "pagedown";
            i = "pageup";
            rightshift = "toggle(main)";
            escape = "toggle(main)";
          };
        };
        in
    {

      internal_keyboard = {
        ids = [ "0000:0000a7ff6013" "0001:0001:d679b64" ]; 
        settings = {
          main = {
            slash = "overload(shift, slash)";
            # leftcontrol = "fn";
            # fn = "leftcontrol";
          } // default-settings.main;

          nav = default-settings.nav;

        };
      };
      default = {
        ids = [ "*" ]; 
        settings = default-settings;
      };
    };

  };

}
