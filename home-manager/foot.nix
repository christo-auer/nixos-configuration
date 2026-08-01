{ pkgs, config, lib, ...}: {

  programs.foot = {
    enable = true;

    settings = {
      "key-bindings" = {
        "scrollback-up-page" = "Control+b";
        "scrollback-down-page" = "Control+f";
        "scrollback-up-line" = "Control+i";
        "scrollback-down-line" = "Control+u";
        "search-start" = "Control+slash";
        "show-urls-copy" = "Control+Shift+u";
        "unicode-input" = "none";
        "prompt-prev" = "Control+p";
        "prompt-next" = "Control+n";
      };
      "search-bindings" = {
        "find-prev" = "Control+p";
        "find-next" = "Control+n";
      };
    };
  };


}
