{ pkgs, ... }: {

  

  programs.eilmeldung = 
  let pipe-through-opencode = pkgs.writeScript "pipe-through-opencode" ''
    #!/usr/bin/env sh

    if [ $# -gt 0 ]; then
      prepend="$@: "
    else 
      prepend="summarize this in at most 5 bullet points: "
    fi

    { echo "$prepend"; cat; } | opencode --agent newsreader run

  '';
  in
  {
    enable = true;

    package = pkgs.eilmeldung;

    settings = {

      mouse_support = true;

      feed_list = [
        "query: \"Marked\" marked"
        "query: \"Reviews\" #reviews"
        "feeds"
          "* categories"
          "tags"
      ];

      startup_commands = ["sync"];
      after_sync_commands = [ 
        "query lastsync"
        "in articles read title:/Anzeige:|g\\+|heise\\+|heise-Angebot/"
        "tag reviews title:review"
        "refresh"
      ];


      login_setup = {
        login_type = "direct_password";
        provider = "freshrss";
        user = "chris";
        url = "http://10.0.64.2:8081/api/greader.php/";
        password = "cmd:pass private/freshrss";
      };

      video_enclosure_command = "mpv {url}";
      audio_enclosure_command = "vlc {url}";

      share_targets = [
        "clipboard"
        "feh feh \"{url}\""
      ];

      input_config.mappings = {
        "; i" = ["cmd hintshare feh"];
        "M-a" = ["pipe null md ${pipe-through-opencode} summarize the article from {url}" ];
        "A" = ["pipe md md ${pipe-through-opencode}" ];
        "a" = ["cmd pipe md md ${pipe-through-opencode}"];
        "Z" = ["cmd pipe html null neomutt -e \"set content_type=text/html\" -s \"{title}\" -- "] ;
        "y" = ["in feeds read" "nextunread"];


      };
    };
  };

}
