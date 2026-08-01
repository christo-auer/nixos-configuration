{ config, pkgs, private-values, ... }: {

  programs.firefox = 
    let
    lock = value: { Value = value; Status = "locked"; };
  in {
    enable = true;

    configPath = "${config.xdg.configHome}/mozilla/firefox";

    nativeMessagingHosts = with pkgs; [
      tridactyl-native
      gopass-jsonapi
    ];

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";

      Preferences = {
        "app.normandy.first_run"                                   = lock false;
        "browser.aboutwelcome.didSeeFinalScreen"                   = lock true;
        "extensions.pocket.enabled"                                = lock false;
        "browser.newtabpage.pinned"                                = lock "";
        "browser.topsites.contile.enabled"                         = lock false;
        "browser.newtabpage.activity-stream.showSponsored"         = lock false;
        "browser.newtabpage.activity-stream.system.showSponsored"  = lock false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock false;
        "browser.translations.automaticallyPopup"                  = lock false;
        "browser.toolbars.bookmarks.visibility"                    = lock "never";
        "signon.rememberSignons"                                   = lock false;
      };
    };

    profiles.default = {

      id = 0;
      isDefault = true;

      search = {
        default = "ddg";
        force = true;
        order = [ "ddg" ];
      };

      bookmarks = {
        force = true;

        settings = private-values.firefox.bookmarks; # imported from private repo


      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        firenvim
        tridactyl
        ublock-origin
        gopass-bridge
      ];

    };

  };
                     }
